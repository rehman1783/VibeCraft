import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

class ClearCacheDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ClearCacheDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final titleColor = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final bodyColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: dialogBg,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.orangeAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Clear Cache',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Text(
        'Clearing cache will delete all your locally saved bookmarks, downloaded wallpapers, and temporary storage. Do you wish to continue?',
        style: TextStyle(color: bodyColor, fontSize: 14, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: bodyColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
