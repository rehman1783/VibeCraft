import 'package:flutter/material.dart';
import 'package:wall_zen/core/theme/app_colors.dart';

/// A pill‑style toggle switch for switching between "Downloaded" and
/// "Favorites" sections.
class DownloadsToggleSwitch extends StatelessWidget {
  final bool isDownloadedSelected;
  final ValueChanged<bool>? onToggle;

  const DownloadsToggleSwitch({
    super.key,
    required this.isDownloadedSelected,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final containerBorder = isDark ? null : Border.all(color: AppColors.lightBorder);
    final inactiveTextColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: containerBg,
        border: containerBorder,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Downloaded tab
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle?.call(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDownloadedSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: isDownloadedSelected
                          ? AppColors.primary
                          : inactiveTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Downloaded',
                      style: TextStyle(
                        color: isDownloadedSelected
                            ? AppColors.primary
                            : inactiveTextColor,
                        fontWeight: isDownloadedSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Favorites tab
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle?.call(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: !isDownloadedSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: !isDownloadedSelected
                          ? AppColors.primary
                          : inactiveTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Favorites',
                      style: TextStyle(
                        color: !isDownloadedSelected
                            ? AppColors.primary
                            : inactiveTextColor,
                        fontWeight: !isDownloadedSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
