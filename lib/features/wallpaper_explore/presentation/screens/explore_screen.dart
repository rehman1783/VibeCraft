import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes.dart';
import '../../../navigation/presentation/cubit/navigation_cubit.dart';
import '../cubit/wallpaper_cubit.dart';
import '../cubit/wallpaper_state.dart';
import '../widgets/category_selector_bar.dart';
import '../widgets/explore_wallpaper_card.dart';
import '../widgets/wallpaper_filter_dialog.dart';
import '../widgets/wallpaper_search_bar.dart';

/// The primary discovery and search hub of VibeCraft.
/// Features a bold Header Area, full-width Search & Filter system,
/// Featured / Quick Categories chips, and a dynamic 2-column Pinterest-style
/// staggered masonry grid.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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

  void _scrollToTopAndRefresh() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    context.read<WallpaperCubit>().fetchWallpapers(isRefresh: true, randomize: true);
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

    return BlocListener<NavigationCubit, NavigationState>(
      listener: (context, navState) {
        if (navState.selectedIndex == 1 && navState.reselectedAt != null) {
          _scrollToTopAndRefresh();
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;

          if (_scrollController.hasClients && _scrollController.offset > 50) {
            _scrollToTopAndRefresh();
          } else {
            // Switch back to Home tab if at top
            context.read<NavigationCubit>().selectTab(0);
          }
        },
        child: SafeArea(
          child: Scaffold(
            body: BlocBuilder<WallpaperCubit, WallpaperState>(
              builder: (context, state) {
                final isInitialLoading =
                    state.status == WallpaperStatus.loading && state.wallpapers.isEmpty;

                // Determine dynamic feed section title
                String sectionTitle = 'Featured Wallpapers';
                if (state.currentQuery != null && state.currentQuery!.isNotEmpty) {
                  sectionTitle = 'Results for "${state.currentQuery}"';
                } else if (state.selectedCategory != null &&
                    state.selectedCategory!.isNotEmpty &&
                    state.selectedCategory != 'All') {
                  sectionTitle = state.selectedCategory!;
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await context
                        .read<WallpaperCubit>()
                        .fetchWallpapers(isRefresh: true, randomize: true);
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // 1. Header Area: Bold "Explore" Title & Quick Action Icon
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Explore',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              // Quick Action Icon (My Favorites / Saved Art shortcut)
                              GestureDetector(
                                onTap: () {
                                  context.read<NavigationCubit>().selectTab(3); // My Art tab
                                },
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surface.withValues(alpha: 0.7)
                                        : AppColors.lightSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : AppColors.lightBorder,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.bookmarks_outlined,
                                    color: isDark
                                        ? AppColors.textPrimary
                                        : AppColors.lightTextPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. Search Bar & Filter System (Relocated as primary search hub)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
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
                      ),

                      // 3. Featured / Quick Categories Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: CategorySelectorBar(
                            selectedCategory: state.selectedCategory,
                            onCategorySelected: (category) {
                              context.read<WallpaperCubit>().selectCategory(category);
                            },
                          ),
                        ),
                      ),

                      // Active Filters Chips Bar (if orientation/color/sort applied)
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

                      // Section Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sectionTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                '${state.wallpapers.length} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Initial Loading Shimmer Staggered Masonry Grid
                      if (isInitialLoading)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverMasonryGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            itemBuilder: (context, index) {
                              final heights = [220.0, 280.0, 240.0, 260.0];
                              return Container(
                                height: heights[index % heights.length],
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              );
                            },
                            childCount: 6,
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
                                    'Try searching for another tag or clearing filters',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.electricBlue,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<WallpaperCubit>().clearFilters();
                                    },
                                    child: const Text('Reset Explore Feed',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                                          .fetchWallpapers(isRefresh: true, randomize: true);
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

                      // 4. Main Content Grid (Pinterest-Style Dynamic 2-Column Staggered Masonry Grid)
                      if (state.wallpapers.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverMasonryGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            itemBuilder: (context, index) {
                              final wallpaperItem = state.wallpapers[index];
                              return ExploreWallpaperCard(
                                wallpaper: wallpaperItem,
                                index: index,
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

                      // Infinite Scroll Loader
                      if (state.status == WallpaperStatus.loading && state.wallpapers.isNotEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),

                      // Bottom padding for floating navigation bar
                      const SliverToBoxAdapter(child: SizedBox(height: 110)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
