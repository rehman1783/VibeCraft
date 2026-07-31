import 'package:flutter/material.dart';
import 'package:wall_zen/features/profile/presentation/widgets/profile_user_card.dart';

/// Extracted custom widget for the Profile Header Card.
class ProfileHeaderCard extends StatelessWidget {
  final String? avatarUrl;
  final String? localPhotoPath;
  final String? fullName;
  final String? email;
  final VoidCallback? onAvatarPickTap;
  final VoidCallback? onEditNameTap;

  const ProfileHeaderCard({
    super.key,
    this.avatarUrl,
    this.localPhotoPath,
    this.fullName,
    this.email,
    this.onAvatarPickTap,
    this.onEditNameTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileUserCard(
      avatarUrl: avatarUrl,
      localPhotoPath: localPhotoPath,
      fullName: fullName,
      email: email,
      onAvatarPickTap: onAvatarPickTap,
      onEditNameTap: onEditNameTap,
    );
  }
}
