import 'package:flutter/material.dart';

class ShiftChip extends StatelessWidget {
  final String shift;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  const ShiftChip({
    super.key,
    required this.shift,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  static Color _shiftColor(String shift) {
    switch (shift) {
      case '0730-1730':
        return const Color(0xFF2563EB); // Blue - morning
      case '1230-2230':
        return const Color(0xFF7C3AED); // Purple - afternoon
      case '2200-0800':
        return const Color(0xFF0F172A); // Dark - night
      case 'RDO':
        return const Color(0xFF059669); // Green - day off
      default:
        return const Color(0xFF64748B); // Slate - unknown
    }
  }

  static IconData _shiftIcon(String shift) {
    switch (shift) {
      case '0730-1730':
        return Icons.wb_sunny_rounded;
      case '1230-2230':
        return Icons.wb_twilight_rounded;
      case '2200-0800':
        return Icons.nights_stay_rounded;
      case 'RDO':
        return Icons.beach_access_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _shiftColor(shift);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = selected
        ? color
        : isDark
            ? color.withOpacity(0.18)
            : color.withOpacity(0.10);

    final textColor = selected
        ? Colors.white
        : color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 3 : 6,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(compact ? 6 : 20),
          border: selected
              ? null
              : Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
              Icon(
                _shiftIcon(shift),
                size: 13,
                color: textColor,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              shift,
              style: TextStyle(
                color: textColor,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
