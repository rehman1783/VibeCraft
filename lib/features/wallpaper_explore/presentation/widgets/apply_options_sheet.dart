import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/wallpaper_repository.dart';

class ApplyOptionsSheet extends StatefulWidget {
  final String imagePathOrUrl;

  const ApplyOptionsSheet({
    super.key,
    required this.imagePathOrUrl,
  });

  @override
  State<ApplyOptionsSheet> createState() => _ApplyOptionsSheetState();
}

class _ApplyOptionsSheetState extends State<ApplyOptionsSheet> {
  bool _isApplying = false;
  WallpaperTarget? _selectedTarget;

  Future<void> _handleApply(WallpaperTarget target, String targetLabel) async {
    if (_isApplying) return;

    setState(() {
      _isApplying = true;
      _selectedTarget = target;
    });

    try {
      WallpaperRepository repository;
      try {
        repository = context.read<WallpaperRepository>();
      } catch (_) {
        repository = sl<WallpaperRepository>();
      }

      final success = await repository.applyWallpaper(
        imagePathOrUrl: widget.imagePathOrUrl,
        target: target,
      );

      if (!mounted) return;

      if (success) {
        // 1. Dismiss BottomSheet instantly
        Navigator.of(context).pop();

        // 2. Show success SnackBar
        AppSnackBar.showSuccess(context, 'Wallpaper applied successfully!');

        // 3. Minimal 1-second delay so user sees success message clearly
        await Future.delayed(const Duration(seconds: 1));

        // 4. Automatically close/minimize app cleanly so user lands on device home screen
        await SystemNavigator.pop();
      } else {
        setState(() {
          _isApplying = false;
          _selectedTarget = null;
        });
        AppSnackBar.showError(context, 'Failed to set wallpaper on device.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isApplying = false;
          _selectedTarget = null;
        });
        AppSnackBar.showError(context, 'Failed to set wallpaper: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Drag Handle & Close Button
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: secondaryTextColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Wallpaper',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Choose where you want to apply this wallpaper',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textColor),
                onPressed: _isApplying ? null : () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Loading Overlay State
          if (_isApplying)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedTarget == WallpaperTarget.home
                          ? 'Applying to Home Screen...'
                          : (_selectedTarget == WallpaperTarget.lock
                              ? 'Applying to Lock Screen...'
                              : 'Applying to Home & Lock Screens...'),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // 3 Interactive Selection Target Cards
            _TargetCard(
              icon: Icons.home_rounded,
              title: 'Home Screen Only',
              subtitle: 'Applies to your main home screen',
              isSelected: _selectedTarget == WallpaperTarget.home,
              isDisabled: _isApplying,
              onTap: () => _handleApply(WallpaperTarget.home, 'Home Screen'),
            ),
            const SizedBox(height: 12),

            _TargetCard(
              icon: Icons.lock_rounded,
              title: 'Lock Screen Only',
              subtitle: 'Applies to your lock screen only',
              isSelected: _selectedTarget == WallpaperTarget.lock,
              isDisabled: _isApplying,
              onTap: () => _handleApply(WallpaperTarget.lock, 'Lock Screen'),
            ),
            const SizedBox(height: 12),

            _TargetCard(
              icon: Icons.phone_android_rounded,
              title: 'Both Screens',
              subtitle: 'Applies to Home & Lock screens',
              isSelected: _selectedTarget == WallpaperTarget.both,
              isDisabled: _isApplying,
              onTap: () => _handleApply(WallpaperTarget.both, 'Home & Lock Screens'),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _TargetCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? AppColors.surface.withValues(alpha: 0.7)
        : AppColors.lightSurface;
    final cardBorder = isSelected
        ? Border.all(color: AppColors.primary, width: 1.8)
        : (isDark
            ? Border.all(color: Colors.white10)
            : Border.all(color: AppColors.lightBorder));
    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: cardBorder,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isSelected ? AppColors.primary : subColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}