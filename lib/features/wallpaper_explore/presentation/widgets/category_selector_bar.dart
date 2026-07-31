import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategorySelectorBar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?>? onCategorySelected;

  /// Max 7 curated categories (including 'All')
  static const List<String> curatedCategories = [
    'All',
    '3D',
    'Nature',
    'Minimal',
    'Cyberpunk',
    'AMOLED',
    'Abstract',
    'Architecture',
  ];

  const CategorySelectorBar({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: curatedCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = curatedCategories[index];
          final isAll = category == 'All';
          final isSelected = isAll
              ? (selectedCategory == null || selectedCategory!.isEmpty)
              : (selectedCategory == category);

          return _CategoryChip(
            label: category,
            isSelected: isSelected,
            onTap: () {
              if (isAll) {
                onCategorySelected?.call(null);
              } else {
                onCategorySelected?.call(category);
              }
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inactiveBg = isDark
        ? AppColors.surface.withValues(alpha: 0.5)
        : AppColors.lightSurface;
    final inactiveBorder = isDark
        ? Colors.transparent
        : AppColors.lightBorder;
    final inactiveTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : inactiveBg,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : inactiveBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : inactiveTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
