import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

class ClearCacheDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ClearCacheDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF13111C) : AppColors.lightSurface;
    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final bodyColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    final iconBgColor = isDark
        ? const Color(0xFF221A3B)
        : const Color(0xFFF0E8FF);
    final iconBorderColor = const Color(0xFF8B3CFF).withValues(alpha: 0.35);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Purple Question Icon Box
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: iconBorderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B3CFF).withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF9D54FF),
                  size: 34,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title: Clear Cache
            Text(
              'Clear Cache',
              style: TextStyle(
                color: titleColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Clearing cache will delete all your locally saved bookmarks, downloaded wallpapers, and temporary storage. Do you wish to continue?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: bodyColor,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Red Pill: IRREVERSIBLE ACTION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D161F)
                    : const Color(0xFFFFECEF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF3B50).withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_rounded,
                    color: Color(0xFFFF3B50),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'IRREVERSIBLE ACTION',
                    style: TextStyle(
                      color: Color(0xFFFF3B50),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Primary Action Button: Continue
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary Action Button: Cancel
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF191724)
                      : Colors.grey.shade100,
                  foregroundColor: titleColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
