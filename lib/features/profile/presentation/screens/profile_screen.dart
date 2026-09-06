import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/theme/theme_cubit.dart';
import 'package:vibe_craft/core/utils/app_snackbar.dart';
import 'package:vibe_craft/core/widgets/report_content_bottom_sheet.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_state.dart';
import 'package:vibe_craft/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:vibe_craft/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vibe_craft/features/profile/presentation/cubit/profile_state.dart';
import 'package:vibe_craft/features/profile/presentation/widgets/clear_cache_dialog.dart';
import 'package:vibe_craft/features/profile/presentation/widgets/edit_name_bottom_sheet.dart';
import 'package:vibe_craft/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:vibe_craft/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:vibe_craft/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:vibe_craft/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchUserProfile();
  }

  void _onLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => LogoutDialog(
        onConfirm: () {
          context.read<AuthCubit>().logout();
        },
      ),
    );
  }

  void _onDeleteAccount(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.deleteAccount);
  }

  void _onClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ClearCacheDialog(
        onConfirm: () {
          context.read<ProfileCubit>().clearCache();
        },
      ),
    );
  }

  void _onShowAiSafetyPolicy(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141624) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Safety & Content Policy',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Google Play Content Moderation Compliance',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'VibeCraft enforces a zero-tolerance policy against offensive AI content, strictly conforming with Google Play AI-Generated Content guidelines:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            _buildSafetyPoint(
              Icons.block_rounded,
              'Prohibited AI Content',
              'Explicit sexuality (NSFW), hate speech, violence, gore, harassment, and copyright violations are strictly blocked.',
              isDark,
            ),
            const SizedBox(height: 10),
            _buildSafetyPoint(
              Icons.flag_outlined,
              'In-App User Reporting',
              'You can flag any wallpaper or AI chat generation directly within the app without leaving to external portals.',
              isDark,
            ),
            const SizedBox(height: 10),
            _buildSafetyPoint(
              Icons.bolt_rounded,
              'Fast Human Moderation',
              'Reports are flagged for review within 24 hours. Offensive outputs are promptly deleted and filters updated.',
              isDark,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ReportContentBottomSheet.show(
                    context: context,
                    contentId: 'profile_report_${DateTime.now().millisecondsSinceEpoch}',
                    contentType: 'ai_chat_response',
                    contentUrlOrText: 'General Safety Report via Profile',
                  );
                },
                icon: const Icon(Icons.flag_rounded, size: 18),
                label: const Text(
                  'Report Inappropriate Content',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPoint(IconData icon, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              AppSnackBar.showInfo(context, 'Signed out successfully.');
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              AppSnackBar.showSuccess(context, state.message);
            } else if (state is CacheClearedSuccess) {
              context.read<WallpaperCubit>().loadDownloadedWallpapers();
              context.read<FavoritesCubit>().onCacheCleared();
              AppSnackBar.showSuccess(context, state.message);
            } else if (state is AccountDeletedSuccess) {
              AppSnackBar.showInfo(context, 'Your account has been deleted.');
              context.read<AuthCubit>().logout();
            } else if (state is ReauthRequired) {
              AppSnackBar.showError(context, state.message);
            } else if (state is ProfileError) {
              AppSnackBar.showError(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              String name = 'User';
              String email = 'No email';
              String? photoUrl;
              String? localPhotoPath;

              if (profileState is ProfileLoaded) {
                name = profileState.displayName;
                email = profileState.email;
                photoUrl = profileState.photoUrl;
                localPhotoPath = profileState.localPhotoPath;
              } else if (profileState is ProfileLoading) {
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated) {
                  name = authState.user.name ?? 'User';
                  email = authState.user.email ?? 'No email';
                }
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        'Profile & Settings',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // User Profile Card
                    if (profileState is ProfileLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else
                      ProfileHeaderCard(
                        avatarUrl: photoUrl,
                        localPhotoPath: localPhotoPath,
                        fullName: name,
                        email: email,
                        onAvatarPickTap: () {
                          context.read<ProfileCubit>().pickAndSaveAvatar();
                        },
                        onEditNameTap: () {
                          EditNameBottomSheet.show(context, name);
                        },
                      ),

                    const SizedBox(height: 12),

                    // Section: Preferences
                    _buildSectionTitle(context, 'PREFERENCES'),
                    const SizedBox(height: 4),
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        final isDarkTheme = themeMode == ThemeMode.dark;
                        return ProfileMenuTile(
                          leadingIcon: isDarkTheme
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          title: isDarkTheme ? 'Dark Theme' : 'Light Theme',
                          subtitle: isDarkTheme
                              ? 'Sleek dark mode enabled'
                              : 'Vibrant light mode enabled',
                          trailing: Switch.adaptive(
                            value: isDarkTheme,
                            onChanged: (value) {
                              context.read<ThemeCubit>().toggleTheme(value);
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Section: Support & Storage
                    _buildSectionTitle(context, 'SUPPORT & STORAGE'),
                    const SizedBox(height: 4),
                    ProfileMenuTile(
                      leadingIcon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy & Terms',
                      subtitle: 'Terms of service & privacy compliance',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.privacyPolicy);
                      },
                    ),
                    ProfileMenuTile(
                      leadingIcon: Icons.shield_outlined,
                      title: 'AI Safety & Content Policy',
                      subtitle: 'Content moderation & in-app reporting',
                      onTap: () => _onShowAiSafetyPolicy(context),
                    ),
                    ProfileMenuTile(
                      leadingIcon: Icons.cleaning_services_outlined,
                      title: 'Clear Cache',
                      subtitle: 'Clear saved bookmarks & image storage',
                      onTap: () => _onClearCache(context),
                    ),

                    const SizedBox(height: 24),

                    // Section: Account Actions
                    _buildSectionTitle(context, 'ACCOUNT ACTIONS'),
                    const SizedBox(height: 4),

                    // Logout
                    ProfileMenuTile(
                      leadingIcon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      iconColor: Colors.orangeAccent,
                      onTap: () => _onLogout(context),
                    ),

                    const SizedBox(height: 8),

                    // Delete Account
                    ProfileMenuTile(
                      leadingIcon: Icons.delete_forever_rounded,
                      title: 'Delete Account',
                      subtitle: 'Permanently remove account & data',
                      isDestructive: true,
                      onTap: () => _onDeleteAccount(context),
                    ),

                    const SizedBox(height: 32),

                    // App Branding & Version Info
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/icons/app_icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'VibeCraft',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Version 1.0.0 • AI-Powered Wallpapers',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark
        ? AppColors.primary.withValues(alpha: 0.8)
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
