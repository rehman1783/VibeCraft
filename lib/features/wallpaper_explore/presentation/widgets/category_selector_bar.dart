import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Redesigned Categories Section displaying a section header ("Categories" & "See All")
/// alongside pill-shaped category chips with electric blue active states and icons.
class CategorySelectorBar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?>? onCategorySelected;
  final VoidCallback? onSeeAllTap;

  /// Curated category items with matching icons
  static const List<CategoryData> categories = [
    CategoryData(name: 'All', icon: Icons.grid_view_rounded),
    CategoryData(name: 'Abstract', icon: Icons.auto_awesome_rounded),
    CategoryData(name: '3D', icon: Icons.view_in_ar_rounded),
    CategoryData(name: 'Minimal', icon: Icons.crop_square_rounded),
    CategoryData(name: 'Cyberpunk', icon: Icons.bolt_rounded),
    CategoryData(name: 'AMOLED', icon: Icons.dark_mode_rounded),
    CategoryData(name: 'Nature', icon: Icons.landscape_rounded),
    CategoryData(name: 'Architecture', icon: Icons.location_city_rounded),
  ];

  const CategorySelectorBar({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Title: "Categories" with "See All" link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              // GestureDetector(
              //   onTap: onSeeAllTap ??
              //       () {
              //         onCategorySelected?.call(null);
              //       },
              //   child: Text(
              //     'See All',
              //     style: TextStyle(
              //       fontSize: 13,
              //       fontWeight: FontWeight.w600,
              //       color: isDark
              //           ? AppColors.textSecondary
              //           : AppColors.lightTextSecondary,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),

        // Horizontal scrolling pill chips
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isAll = cat.name == 'All';
              final isSelected = isAll
                  ? (selectedCategory == null || selectedCategory!.isEmpty)
                  : (selectedCategory == cat.name);

              return _CategoryChip(
                data: cat,
                isSelected: isSelected,
                onTap: () {
                  if (isAll) {
                    onCategorySelected?.call(null);
                  } else {
                    onCategorySelected?.call(cat.name);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryData {
  final String name;
  final IconData icon;

  const CategoryData({required this.name, required this.icon});
}

class _CategoryChip extends StatelessWidget {
  final CategoryData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inactiveBg = isDark
        ? AppColors.surface.withValues(alpha: 0.8)
        : AppColors.lightSurface;
    final inactiveBorder = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.lightBorder;
    final inactiveTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppColors.electricBlue,
                    AppColors.electricBlueSecondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : inactiveBg,
          border: Border.all(
            color: isSelected ? Colors.transparent : inactiveBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.electricBlue.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.auto_awesome_rounded : data.icon,
              size: 16,
              color: isSelected ? Colors.black : inactiveTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              data.name,
              style: TextStyle(
                color: isSelected ? Colors.black : inactiveTextColor,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
