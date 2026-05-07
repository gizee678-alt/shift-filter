import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../utils/ocr_parser.dart';

enum AppState { idle, loading, success, error }

class AppProvider extends ChangeNotifier {
  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // Roster data
  RosterData? _rosterData;
  RosterData? get rosterData => _rosterData;

  AppState _state = AppState.idle;
  AppState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Filters
  String? _selectedDay;
  String? get selectedDay => _selectedDay;

  String? _selectedShift;
  String? get selectedShift => _selectedShift;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Computed
  List<Employee> get filteredEmployees {
    if (_rosterData == null) return [];
    var list = _rosterData!.filterByDayAndShift(_selectedDay, _selectedShift);
    list = _rosterData!.searchByName(list, _searchQuery);
    return list;
  }

  List<String> get availableDays => _rosterData?.days ?? [];

  List<String> get availableShiftsForDay {
    if (_rosterData == null) return kSupportedShifts;
    if (_selectedDay == null) return kSupportedShifts;
    final shifts = <String>{};
    for (final emp in _rosterData!.employees) {
      final shift = emp.shifts[_selectedDay!];
      if (shift != null) shifts.add(shift);
    }
    return kSupportedShifts.where((s) => shifts.contains(s)).toList();
  }

  // OCR processing
  Future<void> processImage(String imagePath) async {
    _state = AppState.loading;
    _rosterData = null;
    _selectedDay = null;
    _selectedShift = null;
    _searchQuery = '';
    notifyListeners();

    try {
      final result = await OcrParser.parseImage(imagePath);
      if (result == null) {
        _state = AppState.error;
        _errorMessage = 'Could not read image. Please try a clearer photo.';
      } else if (result.employees.isEmpty) {
        _state = AppState.error;
        _errorMessage = 'No roster data detected. Make sure the image shows a clear shift table with employee names and shift values (0730-1730, 1230-2230, 2200-0800, RDO).';
      } else {
        _rosterData = result;
        _state = AppState.success;
        // Auto-select first day
        if (result.days.isNotEmpty) {
          _selectedDay = result.days.first;
        }
      }
    } catch (e) {
      _state = AppState.error;
      _errorMessage = 'Error processing image: ${e.toString()}';
    }

    notifyListeners();
  }

  void selectDay(String? day) {
    _selectedDay = day;
    _selectedShift = null; // reset shift when day changes
    notifyListeners();
  }

  void selectShift(String? shift) {
    _selectedShift = shift;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedDay = null;
    _selectedShift = null;
    _searchQuery = '';
    notifyListeners();
  }

  void reset() {
    _rosterData = null;
    _state = AppState.idle;
    _errorMessage = '';
    _selectedDay = null;
    _selectedShift = null;
    _searchQuery = '';
    notifyListeners();
  }
}

class AppProviderScope extends InheritedWidget {
  final AppProvider provider;

  const AppProviderScope({
    super.key,
    required this.provider,
    required super.child,
  });

  static AppProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppProviderScope>();
    assert(scope != null, 'No AppProviderScope found in context');
    return scope!.provider;
  }

  @override
  bool updateShouldNotify(AppProviderScope oldWidget) =>
      oldWidget.provider != provider;
}
