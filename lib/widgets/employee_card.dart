import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/employee.dart';
import 'shift_chip.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final String? selectedDay;
  final int index;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.selectedDay,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final currentShift = selectedDay != null ? employee.shifts[selectedDay!] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(name: employee.name, index: index),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentShift != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          selectedDay ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (currentShift != null)
                  ShiftChip(shift: currentShift, selected: true, onTap: null),
              ],
            ),

            // Show all shifts if no specific day selected
            if (selectedDay == null && employee.shifts.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              _AllShiftsRow(shifts: employee.shifts),
            ],
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, duration: 300.ms);
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final int index;

  const _Avatar({required this.name, required this.index});

  static const _colors = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF0891B2),
    Color(0xFFDB2777),
    Color(0xFF65A30D),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final initials = _getInitials(name);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class _AllShiftsRow extends StatelessWidget {
  final Map<String, String> shifts;

  const _AllShiftsRow({required this.shifts});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: shifts.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                e.key,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 4),
            ShiftChip(shift: e.value, selected: false, onTap: null, compact: true),
          ],
        );
      }).toList(),
    );
  }
}
