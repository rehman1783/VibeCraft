import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

/// Displays the app logo/name and a user avatar/profile button.
class HomeTopHeader extends StatelessWidget {
  final String? userAvatarUrl;
  final String? localPhotoPath;
  final String? userName;
  final VoidCallback? onAvatarTap;

  const HomeTopHeader({
    super.key,
    this.userAvatarUrl,
    this.localPhotoPath,
    this.userName,
    this.onAvatarTap,
  });

  ImageProvider? _getAvatarImage() {
    if (localPhotoPath != null && localPhotoPath!.isNotEmpty) {
      final file = File(localPhotoPath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    if (userAvatarUrl != null && userAvatarUrl!.isNotEmpty) {
      return NetworkImage(userAvatarUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final avatarBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final iconColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    final avatarImage = _getAvatarImage();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App branding
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.wallpaper_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'WallZen',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          // Profile avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: avatarBg,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Icon(Icons.person_rounded, color: iconColor, size: 22)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
