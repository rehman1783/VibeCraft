import 'package:flutter/material.dart';
import 'package:wall_zen/core/theme/app_colors.dart';

/// A single menu option tile used in the Profile screen.
///
/// Supports leading icon, label, trailing widget (e.g., switch, arrow),
/// and an optional destructive style (red color).
class ProfileMenuTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Color? iconColor;

  const ProfileMenuTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isDestructive
        ? AppColors.secondary
        : (iconColor ?? AppColors.primary);

    final tileBackground = isDark
        ? AppColors.surface.withOpacity(0.5)
        : AppColors.lightSurface;

    final titleColor = isDestructive
        ? AppColors.secondary
        : (theme.textTheme.bodyLarge?.color ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary));

    final subtitleColor = theme.textTheme.bodyMedium?.color ??
        (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: tileBackground,
              border: isDark
                  ? null
                  : Border.all(color: AppColors.lightBorder.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                // Leading icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.withOpacity(0.12),
                  ),
                  child: Icon(leadingIcon, color: color, size: 20),
                ),
                const SizedBox(width: 14),

                // Title & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: subtitleColor,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
