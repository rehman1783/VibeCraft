import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

/// Redesigned Header Section displaying User Profile avatar, name distinction,
/// online status indicator, and notification bell icon with active dot marker.
class HomeTopHeader extends StatelessWidget {
  final String? userAvatarUrl;
  final String? localPhotoPath;
  final String? userName;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const HomeTopHeader({
    super.key,
    this.userAvatarUrl,
    this.localPhotoPath,
    this.userName,
    this.onAvatarTap,
    this.onNotificationTap,
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

    final nameText = (userName != null && userName!.trim().isNotEmpty)
        ? userName!.trim()
        : 'Marcus';

    final containerBg = isDark
        ? AppColors.surface.withValues(alpha: 0.7)
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.lightBorder;

    final avatarImage = _getAvatarImage();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User profile avatar & welcome greetings
          Row(
            children: [
              // Avatar with Online Status Indicator
              GestureDetector(
                onTap: onAvatarTap,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark
                            ? AppColors.surface
                            : AppColors.lightSurface,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? Icon(
                                Icons.person_rounded,
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.lightTextPrimary,
                                size: 24,
                              )
                            : null,
                      ),
                    ),
                    // Green Online Status Indicator Dot
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.onlineGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.background : Colors.white,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.onlineGreen,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Welcome text hierarchy
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hello, $nameText',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Notification Bell Icon with Active Dot Marker
          GestureDetector(
            onTap:
                onNotificationTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: containerBg,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                    size: 22,
                  ),
                  // Active Notification Red Dot Marker
                  Positioned(
                    top: 10,
                    right: 11,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.surface : Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFFF3B30), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
