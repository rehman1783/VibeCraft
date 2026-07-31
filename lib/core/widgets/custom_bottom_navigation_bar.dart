import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

/// A modern floating / glassmorphic bottom navigation bar with 3 tabs.
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<_NavItem> _tabs = [
    _NavItem(label: 'Home', icon: Icons.grid_view_rounded),
    _NavItem(label: 'AI', icon: Icons.auto_awesome_rounded),
    _NavItem(label: 'Downloads', icon: Icons.bookmark_rounded),
    _NavItem(label: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBg = isDark
        ? AppColors.surface.withValues(alpha: 0.85)
        : AppColors.lightSurface.withValues(alpha: 0.95);

    final navBorder = isDark
        ? AppColors.primary.withValues(alpha: 0.15)
        : AppColors.lightBorder;

    final shadow = isDark
        ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: navBg,
        border: Border.all(color: navBorder),
        boxShadow: shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: SizedBox(
            height: 74,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = index == currentIndex;
                return Expanded(
                  child: _NavBarItem(
                    isActive: isActive,
                    isDark: isDark,
                    label: tab.label,
                    icon: tab.icon,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem({required this.label, required this.icon});
}

class _NavBarItem extends StatelessWidget {
  final bool isActive;
  final bool isDark;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.isActive,
    required this.isDark,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final activeColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isActive
                  ? activeColor.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),

          const SizedBox(height: 4),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
