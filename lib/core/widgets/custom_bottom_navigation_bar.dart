import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

/// Redesigned floating glassmorphic bottom navigation bar with depth, 5 tabs,
/// electric blue active glow, and an elevated central circular AI STUDIO action button.
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBg = isDark
        ? AppColors.surface.withValues(alpha: 0.88)
        : AppColors.lightSurface.withValues(alpha: 0.95);

    final navBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.lightBorder;

    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Floating Navigation Bar Container
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              color: navBg,
              border: Border.all(color: navBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                if (isDark)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 30,
                    spreadRadius: -4,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 1. HOME
                    _NavBarNavItem(
                      label: 'HOME',
                      icon: Icons.grid_view_rounded,
                      isActive: currentIndex == 0,
                      isDark: isDark,
                      onTap: () => onTabSelected(0),
                    ),

                    // 2. EXPLORE
                    _NavBarNavItem(
                      label: 'EXPLORE',
                      icon: Icons.explore_rounded,
                      isActive: currentIndex == 1,
                      isDark: isDark,
                      onTap: () => onTabSelected(1),
                    ),

                    // Spacer for central elevated AI STUDIO button
                    const SizedBox(width: 56),

                    // 4. MY ART
                    _NavBarNavItem(
                      label: 'MY ART',
                      icon: Icons.collections_rounded,
                      isActive: currentIndex == 3,
                      isDark: isDark,
                      onTap: () => onTabSelected(3),
                    ),

                    // 5. PROFILE
                    _NavBarNavItem(
                      label: 'PROFILE',
                      icon: Icons.person_rounded,
                      isActive: currentIndex == 4,
                      isDark: isDark,
                      onTap: () => onTabSelected(4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. AI STUDIO - Elevated Central Circular Action Button
          Positioned(
            top: 2,
            child: GestureDetector(
              onTap: () => onTabSelected(2),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.badgePurple,
                          AppColors.electricBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withValues(
                            alpha: currentIndex == 2 ? 0.6 : 0.35,
                          ),
                          blurRadius: currentIndex == 2 ? 18 : 12,
                          spreadRadius: currentIndex == 2 ? 2 : 0,
                        ),
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF161824),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.electricBlue,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI STUDIO',
                    style: TextStyle(
                      color: currentIndex == 2
                          ? AppColors.electricBlue
                          : (isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

class _NavBarNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final activeColor = AppColors.electricBlue;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? activeColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
