import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Curated Category Data containing display name, query keywords, and icon.
class CategoryData {
  final String name;
  final String query;
  final IconData icon;
  final String description;

  const CategoryData({
    required this.name,
    required this.query,
    required this.icon,
    required this.description,
  });
}

/// Dynamic, rich categories catalog for VibeCraft
class AppCategories {
  static const List<CategoryData> all = [
    CategoryData(
      name: 'All',
      query: 'wallpapers',
      icon: Icons.grid_view_rounded,
      description: 'Discover trending wallpapers across all styles',
    ),
    CategoryData(
      name: 'Abstract',
      query: 'abstract art wallpaper colorful',
      icon: Icons.auto_awesome_rounded,
      description: 'Dynamic fluid shapes, gradients & modern art',
    ),
    CategoryData(
      name: '3D & CGI',
      query: '3d render wallpaper futuristic',
      icon: Icons.view_in_ar_rounded,
      description: 'Cinema 4D, Blender, octane & geometric renders',
    ),
    CategoryData(
      name: 'Cyberpunk',
      query: 'cyberpunk synthwave neon night city',
      icon: Icons.bolt_rounded,
      description: 'Sci-fi neon lights, futuristic tech & synthwave',
    ),
    CategoryData(
      name: 'AMOLED',
      query: 'amoled black dark minimalist',
      icon: Icons.dark_mode_rounded,
      description: 'Deep pitch-black OLED battery-saving wallpapers',
    ),
    CategoryData(
      name: 'Anime',
      query: 'anime aesthetic scenery artwork',
      icon: Icons.animation_rounded,
      description: 'Vibrant manga art, anime landscapes & characters',
    ),
    CategoryData(
      name: 'Nature',
      query: 'nature forest trees scenery',
      icon: Icons.forest_rounded,
      description: 'Lush green forests, rivers & scenic landscapes',
    ),
    CategoryData(
      name: 'Space & Galaxy',
      query: 'space galaxy stars universe nebula',
      icon: Icons.nights_stay_rounded,
      description: 'Nebulae, planets, cosmos & twinkling starry skies',
    ),
    CategoryData(
      name: 'Ocean & Sea',
      query: 'ocean sea waves underwater beach',
      icon: Icons.water_rounded,
      description: 'Deep blue water, tropical beaches & majestic waves',
    ),
    CategoryData(
      name: 'Architecture',
      query: 'architecture modern skyscrapers building',
      icon: Icons.location_city_rounded,
      description: 'Modern city structures, brutalism & interior geometry',
    ),
    CategoryData(
      name: 'Minimalist',
      query: 'minimalist clean aesthetic simple',
      icon: Icons.crop_square_rounded,
      description: 'Clean, elegant, distraction-free aesthetic art',
    ),
    CategoryData(
      name: 'Supercars',
      query: 'supercars luxury sports hypercar',
      icon: Icons.directions_car_rounded,
      description: 'Exotic hypercars, luxury vehicles & racing beasts',
    ),
    CategoryData(
      name: 'Motorcycles',
      query: 'superbike motorcycle street bike',
      icon: Icons.two_wheeler_rounded,
      description: 'Aggressive superbikes, choppers & moto gear',
    ),
    CategoryData(
      name: 'Neon & Glow',
      query: 'neon glow luminescent vibrant night',
      icon: Icons.lightbulb_rounded,
      description: 'Electric luminescence, glowing signs & dark vibrancy',
    ),
    CategoryData(
      name: 'Gaming',
      query: 'gaming video games arcade retro',
      icon: Icons.sports_esports_rounded,
      description: 'Epic gaming battle stations, pixel art & consoles',
    ),
    CategoryData(
      name: 'Animals & Wildlife',
      query: 'wildlife animals majestic pets',
      icon: Icons.pets_rounded,
      description: 'Lions, tigers, wolves, birds & wildlife photography',
    ),
    CategoryData(
      name: 'Flowers & Floral',
      query: 'flowers blossom botanical floral',
      icon: Icons.local_florist_rounded,
      description: 'Blooming roses, cherry blossoms & botanical closeups',
    ),
    CategoryData(
      name: 'Sunsets & Sky',
      query: 'sunset sunrise sky clouds golden hour',
      icon: Icons.wb_twilight_rounded,
      description: 'Warm golden hour, twilight horizons & pastel clouds',
    ),
    CategoryData(
      name: 'Mountains',
      query: 'mountains alpine snow peaks valley',
      icon: Icons.landscape_rounded,
      description: 'Towering mountain peaks, alpine summits & hiking views',
    ),
    CategoryData(
      name: 'City Nights',
      query: 'city night lights urban skyline',
      icon: Icons.nightlife_rounded,
      description: 'Downtown skyscrapers glowing with nightlife luster',
    ),
    CategoryData(
      name: 'Pastel & Aesthetic',
      query: 'pastel aesthetic soft colors dreamy',
      icon: Icons.palette_rounded,
      description: 'Soft dreamy tones, lo-fi vibes & aesthetic gradients',
    ),
    CategoryData(
      name: 'Fantasy & Magic',
      query: 'fantasy magical mythical artwork',
      icon: Icons.flare_rounded,
      description: 'Mythical creatures, enchanted realms & magic worlds',
    ),
    CategoryData(
      name: 'Macro & Textures',
      query: 'macro texture pattern detail material',
      icon: Icons.grain_rounded,
      description: 'High-detail surfaces, water droplets & abstract patterns',
    ),
    CategoryData(
      name: 'Art & Illustration',
      query: 'digital art illustration painting canvas',
      icon: Icons.brush_rounded,
      description: 'Expressive paintings, concept art & digital graphics',
    ),
    CategoryData(
      name: 'Cyber & Tech',
      query: 'technology futuristic matrix digital',
      icon: Icons.memory_rounded,
      description: 'Circuits, coding, matrix code & tech innovation',
    ),
    CategoryData(
      name: 'Vintage & Retro',
      query: 'vintage retro 80s 90s nostalgia',
      icon: Icons.camera_alt_rounded,
      description: 'Film grain photography, 80s synth & retro nostalgia',
    ),
  ];

  static String getSearchQueryForCategory(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty || categoryName == 'All') {
      return 'wallpapers';
    }
    final found = all.firstWhere(
      (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => CategoryData(
        name: categoryName,
        query: '$categoryName wallpaper',
        icon: Icons.image_rounded,
        description: '',
      ),
    );
    return found.query;
  }
}

/// Redesigned Categories Section displaying a section header ("Categories" & "See All")
/// alongside pill-shaped category chips with electric blue active states and icons.
class CategorySelectorBar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?>? onCategorySelected;
  final VoidCallback? onSeeAllTap;

  const CategorySelectorBar({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
    this.onSeeAllTap,
  });

  void _openAllCategoriesSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Categories',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${AppCategories.all.length} Curated Collections',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Categories Grid
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: AppCategories.all.length,
                      itemBuilder: (gridContext, index) {
                        final cat = AppCategories.all[index];
                        final isAll = cat.name == 'All';
                        final isSelected = isAll
                            ? (selectedCategory == null || selectedCategory!.isEmpty)
                            : (selectedCategory == cat.name);

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            if (isAll) {
                              onCategorySelected?.call(null);
                            } else {
                              onCategorySelected?.call(cat.name);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.electricBlue.withValues(alpha: 0.15)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : AppColors.lightInputFill),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.electricBlue
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : AppColors.lightBorder),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.electricBlue
                                            : (isDark
                                                ? Colors.white.withValues(alpha: 0.08)
                                                : Colors.white),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        cat.icon,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.black
                                            : (isDark
                                                ? AppColors.textPrimary
                                                : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.electricBlue,
                                        size: 18,
                                      ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? (isDark
                                                ? AppColors.electricBlue
                                                : AppColors.primary)
                                            : (isDark
                                                ? AppColors.textPrimary
                                                : AppColors.lightTextPrimary),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (cat.description.isNotEmpty)
                                      Text(
                                        cat.description,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? AppColors.textSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
              GestureDetector(
                onTap: onSeeAllTap ?? () => _openAllCategoriesSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All (${AppCategories.all.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.electricBlue
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: isDark
                            ? AppColors.electricBlue
                            : AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal scrolling pill chips
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppCategories.all.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = AppCategories.all[index];
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
