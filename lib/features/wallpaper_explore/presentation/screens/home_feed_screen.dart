import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../navigation/presentation/cubit/navigation_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../../routes.dart';
import '../cubit/wallpaper_cubit.dart';
import '../cubit/wallpaper_state.dart';
import '../widgets/ai_feature_card.dart';
import '../widgets/category_selector_bar.dart';
import '../widgets/home_top_header.dart';
import '../widgets/wallpaper_card.dart';
import '../widgets/wallpaper_filter_dialog.dart';
import '../widgets/wallpaper_search_bar.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<WallpaperCubit>();
      if (cubit.state.wallpapers.isEmpty) {
        cubit.fetchWallpapers(isRefresh: true);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<WallpaperCubit>().fetchWallpapers();
    }
  }

  void _openFilterModal(BuildContext context, WallpaperState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WallpaperFilterDialog(
        initialOrientation: state.selectedOrientation,
        initialColor: state.selectedColor,
        initialSortBy: state.selectedSort,
        onApply: ({color, orientation, sortBy}) {
          context.read<WallpaperCubit>().applyFilters(
                orientation: orientation,
                color: color,
                sortBy: sortBy,
              );
        },
        onReset: () {
          context.read<WallpaperCubit>().clearFilters();
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<WallpaperCubit, WallpaperState>(
          builder: (context, state) {
            final isInitialLoading =
                state.status == WallpaperStatus.loading && state.wallpapers.isEmpty;

            // Determine dynamic section title
            String sectionTitle = 'Daily Picks';
            if (state.currentQuery != null && state.currentQuery!.isNotEmpty) {
              sectionTitle = 'Results for "${state.currentQuery}"';
            } else if (state.selectedCategory != null &&
                state.selectedCategory!.isNotEmpty &&
                state.selectedCategory != 'All') {
              sectionTitle = state.selectedCategory!;
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<WallpaperCubit>().fetchWallpapers(isRefresh: true);
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Header Section (User Profile)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                      child: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, profileState) {
                          String? photoUrl;
                          String? localPhotoPath;
                          String? name;

                          if (profileState is ProfileLoaded) {
                            photoUrl = profileState.photoUrl;
                            localPhotoPath = profileState.localPhotoPath;
                            name = profileState.displayName;
                          }

                          return HomeTopHeader(
                            userAvatarUrl: photoUrl,
                            localPhotoPath: localPhotoPath,
                            userName: name,
                            onAvatarTap: () {
                              context.read<NavigationCubit>().selectTab(4); // Profile tab
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // 2. Search Bar
                  SliverToBoxAdapter(
                    child: WallpaperSearchBar(
                      controller: _searchController,
                      recentSearches: state.recentSearches,
                      onFilterTap: () => _openFilterModal(context, state),
                      onSubmitted: (query) {
                        context.read<WallpaperCubit>().searchWallpapers(query);
                      },
                      onClear: () {
                        context.read<WallpaperCubit>().searchWallpapers('');
                      },
                    ),
                  ),

                  // 3. AI Feature Callout Card ("Launch Studio")
                  SliverToBoxAdapter(
                    child: AIFeatureCard(
                      onLaunchStudio: () {
                        context.read<NavigationCubit>().selectTab(2); // AI Studio tab
                      },
                    ),
                  ),

                  // Recent Search History Pills
                  if (state.recentSearches.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Searches',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<WallpaperCubit>().clearRecentSearches();
                                  },
                                  child: const Text(
                                    'Clear All',
                                    style: TextStyle(
                                      color: AppColors.electricBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: state.recentSearches.map((query) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ActionChip(
                                      avatar: const Icon(Icons.history_rounded, size: 14),
                                      label: Text(query),
                                      backgroundColor: isDark
                                          ? AppColors.surface.withValues(alpha: 0.8)
                                          : AppColors.lightSurface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isDark
                                              ? AppColors.primary.withValues(alpha: 0.2)
                                              : AppColors.lightBorder,
                                        ),
                                      ),
                                      onPressed: () {
                                        _searchController.text = query;
                                        context
                                            .read<WallpaperCubit>()
                                            .searchWallpapers(query);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 4. Categories Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: CategorySelectorBar(
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: (category) {
                          context.read<WallpaperCubit>().selectCategory(category);
                        },
                      ),
                    ),
                  ),

                  // Active Filters Chips (if orientation/color applied)
                  if (state.selectedOrientation != null ||
                      state.selectedColor != null ||
                      state.selectedSort != 'popular')
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (state.selectedOrientation != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Chip(
                                    label: Text('Orientation: ${state.selectedOrientation}'),
                                    onDeleted: () {
                                      context.read<WallpaperCubit>().applyFilters(
                                            color: state.selectedColor,
                                            sortBy: state.selectedSort,
                                          );
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              if (state.selectedColor != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Chip(
                                    label: Text('Color: ${state.selectedColor}'),
                                    onDeleted: () {
                                      context.read<WallpaperCubit>().applyFilters(
                                            orientation: state.selectedOrientation,
                                            sortBy: state.selectedSort,
                                          );
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              if (state.selectedSort != 'popular')
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Chip(
                                    label: Text('Sort: ${state.selectedSort}'),
                                    onDeleted: () {
                                      context.read<WallpaperCubit>().applyFilters(
                                            orientation: state.selectedOrientation,
                                            color: state.selectedColor,
                                            sortBy: 'popular',
                                          );
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 5. Daily Picks Section Title & Multi-Page Dots Indicator
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sectionTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                  letterSpacing: -0.3,
                                ),
                          ),

                          // Multi-page Indicator (Three small purple dots with an active one)
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 14,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Initial Loading Shimmer
                  if (isInitialLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          },
                          childCount: 4,
                        ),
                      ),
                    ),

                  // Empty State
                  if (state.status == WallpaperStatus.loaded && state.wallpapers.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.image_search_rounded,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No wallpapers found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try searching for another keyword or clearing filters',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<WallpaperCubit>().clearFilters();
                                },
                                child: const Text('Reset Feed',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Error State
                  if (state.status == WallpaperStatus.failure && state.wallpapers.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.cloud_off_rounded,
                                size: 64,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  (state.errorMessage != null &&
                                          !state.errorMessage!.contains('Exception') &&
                                          !state.errorMessage!.contains('Failure'))
                                      ? state.errorMessage!
                                      : 'No Internet Connection. Please check your network and try again.',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                onPressed: () {
                                  context
                                      .read<WallpaperCubit>()
                                      .fetchWallpapers(isRefresh: true);
                                },
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white),
                                label: const Text('Retry',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Main Wallpaper 2x2 Clean Grid of Tall Portrait Cards
                  if (state.wallpapers.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final wallpaperItem = state.wallpapers[index];
                            return WallpaperCard(
                              wallpaper: wallpaperItem,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.detail,
                                  arguments: wallpaperItem,
                                );
                              },
                            );
                          },
                          childCount: state.wallpapers.length,
                        ),
                      ),
                    ),

                  // Infinite Scroll Loader
                  if (state.status == WallpaperStatus.loading && state.wallpapers.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),

                  // Bottom padding for floating navigation bar height
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
