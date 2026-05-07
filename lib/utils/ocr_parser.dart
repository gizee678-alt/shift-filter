import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/employee.dart';

class OcrParser {
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Shift aliases for fuzzy matching
  static const _shiftAliases = <String, String>{
    '0730': '0730-1730',
    '1730': '0730-1730',
    '073O': '0730-1730',
    '07:30': '0730-1730',
    '1230': '1230-2230',
    '2230': '1230-2230',
    '12:30': '1230-2230',
    '2200': '2200-0800',
    '0800': '2200-0800',
    '22:00': '2200-0800',
    'NIGHT': '2200-0800',
    'RDO': 'RDO',
    'OFF': 'RDO',
    'DAY OFF': 'RDO',
    'REST': 'RDO',
  };

  static const _dayPatterns = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY',
  ];

  static Future<RosterData?> parseImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return _parseRecognizedText(recognizedText, imagePath);
    } catch (e) {
      return null;
    }
  }

  static RosterData _parseRecognizedText(RecognizedText text, String imagePath) {
    // Collect all text blocks with their bounding boxes
    final lines = <_TextLine>[];

    for (final block in text.blocks) {
      for (final line in block.lines) {
        if (line.boundingBox != null) {
          lines.add(_TextLine(
            text: line.text.trim(),
            top: line.boundingBox!.top,
            left: line.boundingBox!.left,
            bottom: line.boundingBox!.bottom,
            right: line.boundingBox!.right,
          ));
        }
      }
    }

    if (lines.isEmpty) return _emptyRoster(imagePath);

    // Sort lines top-to-bottom, left-to-right
    lines.sort((a, b) {
      final rowDiff = a.top - b.top;
      if (rowDiff.abs() > 10) return rowDiff.toInt();
      return a.left.compareTo(b.left);
    });

    // Group lines into rows by vertical proximity
    final rows = <List<_TextLine>>[];
    List<_TextLine> currentRow = [];
    double lastTop = -1;

    for (final line in lines) {
      if (lastTop < 0 || (line.top - lastTop).abs() <= 20) {
        currentRow.add(line);
      } else {
        if (currentRow.isNotEmpty) rows.add(List.from(currentRow));
        currentRow = [line];
      }
      lastTop = line.top;
    }
    if (currentRow.isNotEmpty) rows.add(currentRow);

    // Find header row (contains day names)
    int headerRowIndex = -1;
    List<String> detectedDays = [];

    for (int i = 0; i < rows.length; i++) {
      final rowText = rows[i].map((l) => l.text.toUpperCase()).join(' ');
      final dayMatches = _dayPatterns.where((d) => rowText.contains(d)).toList();
      if (dayMatches.length >= 3) {
        headerRowIndex = i;
        // Preserve order from row
        for (final cell in rows[i]) {
          final up = cell.text.toUpperCase().trim();
          for (final day in _dayPatterns) {
            if (up.contains(day) && !detectedDays.contains(up)) {
              detectedDays.add(_normalizeDay(up));
              break;
            }
          }
        }
        break;
      }
    }

    // If no day header found, try numeric approach (1-31)
    if (headerRowIndex < 0) {
      for (int i = 0; i < rows.length; i++) {
        final numbers = rows[i]
            .where((l) => RegExp(r'^\d{1,2}$').hasMatch(l.text.trim()))
            .toList();
        if (numbers.length >= 5) {
          headerRowIndex = i;
          detectedDays = numbers.map((l) => l.text.trim()).toList();
          break;
        }
      }
    }

    final employees = <Employee>[];

    if (headerRowIndex >= 0 && detectedDays.isNotEmpty) {
      // Get the x-positions of day columns
      final headerRow = rows[headerRowIndex];
      final dayColumns = <_ColInfo>[];

      for (int i = 0; i < headerRow.length; i++) {
        final cell = headerRow[i];
        final up = cell.text.toUpperCase().trim();
        final isDay = _dayPatterns.any((d) => up.contains(d)) ||
            RegExp(r'^\d{1,2}$').hasMatch(up);
        if (isDay) {
          dayColumns.add(_ColInfo(
            label: _normalizeDay(up),
            centerX: (cell.left + cell.right) / 2,
            left: cell.left,
            right: cell.right,
          ));
        }
      }

      // Parse employee rows
      for (int i = headerRowIndex + 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        // First cell is likely employee name
        final firstCell = row.first;
        final name = _cleanName(firstCell.text);
        if (name.isEmpty || _isHeaderLike(name)) continue;
        if (name.length < 2) continue;

        final shiftMap = <String, String>{};

        for (final col in dayColumns) {
          // Find cell closest to this column's x center
          _TextLine? best;
          double bestDist = double.infinity;

          for (final cell in row) {
            if (cell == firstCell) continue;
            final cellCenter = (cell.left + cell.right) / 2;
            final dist = (cellCenter - col.centerX).abs();
            if (dist < bestDist && dist < 80) {
              bestDist = dist;
              best = cell;
            }
          }

          if (best != null) {
            final shift = _normalizeShift(best.text);
            if (shift != null) {
              shiftMap[col.label] = shift;
            }
          }
        }

        if (shiftMap.isNotEmpty) {
          employees.add(Employee(name: name, shifts: shiftMap));
        }
      }
    }

    // Fallback: brute force scan all text for shift patterns
    if (employees.isEmpty) {
      employees.addAll(_fallbackParse(text));
      detectedDays = employees
          .expand((e) => e.shifts.keys)
          .toSet()
          .toList();
    }

    return RosterData(
      employees: employees,
      days: detectedDays,
      parsedAt: DateTime.now(),
      imagePath: imagePath,
    );
  }

  static List<Employee> _fallbackParse(RecognizedText text) {
    final result = <Employee>[];
    final allText = text.text;
    final lines = allText.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Check if this line contains shift values
      final shiftMatches = <String>[];
      for (final alias in _shiftAliases.entries) {
        if (line.toUpperCase().contains(alias.key)) {
          shiftMatches.add(alias.value);
        }
      }

      if (shiftMatches.isNotEmpty && i > 0) {
        // Previous line might be the employee name
        final prevLine = lines[i - 1].trim();
        final name = _cleanName(prevLine);
        if (name.isNotEmpty && !_isHeaderLike(name)) {
          final shifts = <String, String>{};
          for (int j = 0; j < shiftMatches.length; j++) {
            shifts['Day ${j + 1}'] = shiftMatches[j];
          }
          result.add(Employee(name: name, shifts: shifts));
        }
      }
    }

    return result;
  }

  static String _normalizeDay(String raw) {
    final up = raw.toUpperCase().trim();
    const map = {
      'MONDAY': 'Mon', 'MON': 'Mon',
      'TUESDAY': 'Tue', 'TUE': 'Tue',
      'WEDNESDAY': 'Wed', 'WED': 'Wed',
      'THURSDAY': 'Thu', 'THU': 'Thu',
      'FRIDAY': 'Fri', 'FRI': 'Fri',
      'SATURDAY': 'Sat', 'SAT': 'Sat',
      'SUNDAY': 'Sun', 'SUN': 'Sun',
    };
    return map[up] ?? raw.trim();
  }

  static String? _normalizeShift(String raw) {
    final up = raw.toUpperCase().trim().replaceAll(' ', '');

    // Direct match
    for (final shift in kSupportedShifts) {
      if (up == shift.toUpperCase().replaceAll('-', '').replaceAll(':', '')) {
        return shift;
      }
    }

    // Alias match
    for (final entry in _shiftAliases.entries) {
      if (up.contains(entry.key.replaceAll(' ', ''))) {
        return entry.value;
      }
    }

    // Pattern matching for time ranges like "07:30-17:30" or "0730-1730"
    final timeRange = RegExp(r'(\d{2}):?(\d{2})\s*[-–]\s*(\d{2}):?(\d{2})');
    final match = timeRange.firstMatch(raw);
    if (match != null) {
      final start = '${match.group(1)}${match.group(2)}';
      final end = '${match.group(3)}${match.group(4)}';
      final combined = '$start-$end';
      for (final shift in kSupportedShifts) {
        if (shift.replaceAll(':', '') == combined) return shift;
      }
      // Return as-is if matches time pattern but not in our list
      return combined;
    }

    return null;
  }

  static String _cleanName(String raw) {
    // Remove common non-name characters but keep spaces
    return raw
        .replaceAll(RegExp(r'[|\\/_=+*#@!]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isHeaderLike(String text) {
    final up = text.toUpperCase();
    final headerKeywords = [
      'NAME', 'EMPLOYEE', 'STAFF', 'NO', 'NUM', 'ID', 'ROSTER',
      'SCHEDULE', 'SHIFT', 'WEEK', 'MONTH', 'DATE', 'TOTAL',
    ];
    return headerKeywords.any((k) => up.contains(k));
  }

  static RosterData _emptyRoster(String imagePath) {
    return RosterData(
      employees: [],
      days: [],
      parsedAt: DateTime.now(),
      imagePath: imagePath,
    );
  }

  static void dispose() {
    _textRecognizer.close();
  }
}

class _TextLine {
  final String text;
  final double top, left, bottom, right;

  const _TextLine({
    required this.text,
    required this.top,
    required this.left,
    required this.bottom,
    required this.right,
  });
}

class _ColInfo {
  final String label;
  final double centerX, left, right;

  const _ColInfo({
    required this.label,
    required this.centerX,
    required this.left,
    required this.right,
  });
}
