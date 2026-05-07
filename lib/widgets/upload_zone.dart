import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UploadZone extends StatelessWidget {
  final VoidCallback onTap;

  const UploadZone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        decoration: BoxDecoration(
          color: isDark
              ? primary.withOpacity(0.07)
              : primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primary.withOpacity(0.25),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.document_scanner_rounded,
                size: 40,
                color: primary,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.06, duration: 1500.ms, curve: Curves.easeInOut),

            const SizedBox(height: 24),

            Text(
              'Scan Roster Sheet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Take a photo or upload a screenshot\nof your Excel shift schedule',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.55),
                    height: 1.5,
                  ),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: primary,
                  onTap: onTap,
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: onTap,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.offline_bolt_rounded,
                  size: 14,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '100% offline — no internet required',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
