import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wall_zen/core/theme/app_colors.dart';

/// Displays the user's profile avatar with a camera edit badge,
/// display name with an edit pencil icon, and email address in a glassmorphic card.
class ProfileUserCard extends StatelessWidget {
  final String? avatarUrl;
  final String? localPhotoPath;
  final String? fullName;
  final String? email;
  final VoidCallback? onAvatarPickTap;
  final VoidCallback? onEditNameTap;

  const ProfileUserCard({
    super.key,
    this.avatarUrl,
    this.localPhotoPath,
    this.fullName,
    this.email,
    this.onAvatarPickTap,
    this.onEditNameTap,
  });

  ImageProvider? _getAvatarImage() {
    if (localPhotoPath != null && localPhotoPath!.isNotEmpty) {
      final file = File(localPhotoPath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return NetworkImage(avatarUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? AppColors.surface.withValues(alpha: 0.7)
        : AppColors.lightSurface;

    final cardBorder = isDark
        ? AppColors.primary.withValues(alpha: 0.15)
        : AppColors.lightBorder;

    final nameColor = theme.textTheme.bodyLarge?.color ??
        (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);

    final emailColor = theme.textTheme.bodyMedium?.color ??
        (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary);

    final avatarImage = _getAvatarImage();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cardBg,
        border: Border.all(color: cardBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Avatar Stack with Camera Edit Badge Overlay
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 38,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              if (onAvatarPickTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: onAvatarPickTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.surface : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Name & Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName != null && fullName!.isNotEmpty
                            ? fullName!
                            : 'User',
                        style: TextStyle(
                          color: nameColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (onEditNameTap != null)
                      InkWell(
                        onTap: onEditNameTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email != null && email!.isNotEmpty
                      ? email!
                      : 'No email address',
                  style: TextStyle(
                    color: emailColor,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
