import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WallpaperFilterDialog extends StatefulWidget {
  final String? initialOrientation;
  final String? initialColor;
  final String initialSortBy;
  final Function({
    String? orientation,
    String? color,
    String? sortBy,
  }) onApply;
  final VoidCallback onReset;

  const WallpaperFilterDialog({
    super.key,
    this.initialOrientation,
    this.initialColor,
    required this.initialSortBy,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<WallpaperFilterDialog> createState() => _WallpaperFilterDialogState();
}

class _WallpaperFilterDialogState extends State<WallpaperFilterDialog> {
  late String? _selectedOrientation;
  late String? _selectedColor;
  late String _selectedSortBy;

  final List<Map<String, String?>> _orientations = [
    {'label': 'All', 'value': null},
    {'label': 'Portrait 📱', 'value': 'portrait'},
    {'label': 'Landscape 🖼️', 'value': 'landscape'},
    {'label': 'Square ⏹️', 'value': 'squarish'},
  ];

  final List<Map<String, dynamic>> _colors = [
    {'label': 'All', 'value': null, 'color': null},
    {'label': 'B&W', 'value': 'black_and_white', 'color': Colors.grey},
    {'label': 'Black', 'value': 'black', 'color': Colors.black},
    {'label': 'White', 'value': 'white', 'color': Colors.white},
    {'label': 'Red', 'value': 'red', 'color': Colors.red},
    {'label': 'Blue', 'value': 'blue', 'color': Colors.blue},
    {'label': 'Green', 'value': 'green', 'color': Colors.green},
    {'label': 'Yellow', 'value': 'yellow', 'color': Colors.yellow},
    {'label': 'Orange', 'value': 'orange', 'color': Colors.orange},
    {'label': 'Purple', 'value': 'purple', 'color': Colors.purple},
    {'label': 'Teal', 'value': 'teal', 'color': Colors.teal},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Popular 🔥', 'value': 'popular'},
    {'label': 'Latest ⏱️', 'value': 'latest'},
    {'label': 'Relevant 🎯', 'value': 'relevant'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedOrientation = widget.initialOrientation;
    _selectedColor = widget.initialColor;
    _selectedSortBy = widget.initialSortBy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Wallpapers',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedOrientation = null;
                      _selectedColor = null;
                      _selectedSortBy = 'popular';
                    });
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset All', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Orientation
            Text('Orientation', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _orientations.map((opt) {
                final isSelected = _selectedOrientation == opt['value'];
                return ChoiceChip(
                  label: Text(opt['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  onSelected: (val) {
                    setState(() => _selectedOrientation = opt['value']);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Color Filters
            Text('Color Palette', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((opt) {
                final isSelected = _selectedColor == opt['value'];
                final color = opt['color'] as Color?;
                return ChoiceChip(
                  avatar: color != null
                      ? Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400, width: 1),
                          ),
                        )
                      : null,
                  label: Text(opt['label'] as String),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  onSelected: (val) {
                    setState(() => _selectedColor = opt['value'] as String?);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Sort By
            Text('Sort By', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sortOptions.map((opt) {
                final isSelected = _selectedSortBy == opt['value'];
                return ChoiceChip(
                  label: Text(opt['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  onSelected: (val) {
                    setState(() => _selectedSortBy = opt['value']!);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  widget.onApply(
                    orientation: _selectedOrientation,
                    color: _selectedColor,
                    sortBy: _selectedSortBy,
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
