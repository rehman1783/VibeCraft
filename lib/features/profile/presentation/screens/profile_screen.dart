import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wall_zen/core/theme/app_colors.dart';
import 'package:wall_zen/core/theme/theme_cubit.dart';
import 'package:wall_zen/core/utils/app_snackbar.dart';
import 'package:wall_zen/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wall_zen/features/auth/presentation/cubit/auth_state.dart';
import 'package:wall_zen/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:wall_zen/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:wall_zen/features/profile/presentation/cubit/profile_state.dart';
import 'package:wall_zen/features/profile/presentation/widgets/clear_cache_dialog.dart';
import 'package:wall_zen/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:wall_zen/features/profile/presentation/widgets/edit_name_bottom_sheet.dart';
import 'package:wall_zen/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:wall_zen/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:wall_zen/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:wall_zen/routes.dart';

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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surface
            : AppColors.lightSurface,
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out of WallZen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _onDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteAccountDialog(
        onConfirm: () {
          context.read<ProfileCubit>().deleteAccount();
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
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
                          child: CircularProgressIndicator(color: AppColors.primary),
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
                        Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
                      },
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
    final color = isDark ? AppColors.primary.withValues(alpha: 0.8) : AppColors.primary;

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
