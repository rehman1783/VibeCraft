// lib/core/widgets/vibe_list_tile.dart
import 'package:flutter/material.dart';

class VibeListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const VibeListTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(leadingIcon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            : null,
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}