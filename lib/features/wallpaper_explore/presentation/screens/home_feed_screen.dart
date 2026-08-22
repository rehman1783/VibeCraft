import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
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

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<WallpaperCubit>();
      if (cubit.state.wallpapers.isEmpty) {
        cubit.fetchWallpapers(isRefresh: true, randomize: true);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<WallpaperCubit>().fetchWallpapers();
    }
  }

  Future<void> _scrollToTopAndRefresh() async {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    if (mounted) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      context.read<WallpaperCubit>().fetchWallpapers(isRefresh: true, randomize: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<NavigationCubit, NavigationState>(
          listener: (context, navState) {
            if (navState.selectedIndex == 0 && navState.reselectedAt != null) {
              _scrollToTopAndRefresh();
            }
          },
        ),
        BlocListener<WallpaperCubit, WallpaperState>(
          listener: (context, state) {
            if (state.status == WallpaperStatus.failure &&
                state.wallpapers.isNotEmpty &&
                state.errorMessage != null) {
              AppSnackBar.showError(context, state.errorMessage!);
            }
          },
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;

          if (_scrollController.hasClients && _scrollController.offset > 50) {
            _scrollToTopAndRefresh();
          }
        },
        child: SafeArea(
          child: Scaffold(
            body: BlocBuilder<WallpaperCubit, WallpaperState>(
              builder: (context, state) {
                final isInitialLoading =
                    state.status == WallpaperStatus.loading && state.wallpapers.isEmpty;

                // Determine dynamic section title
                String sectionTitle = 'Daily Picks';
                if (state.selectedCategory != null &&
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
                      // 1. Header Section (User Profile with Vector Person Icon by default)
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

                      // 2. AI Feature Callout Card ("Craft Your Reality with AI") - Positioned directly below Header
                      SliverToBoxAdapter(
                        child: AIFeatureCard(
                          onLaunchStudio: () {
                            context.read<NavigationCubit>().selectTab(2); // AI Studio tab
                          },
                        ),
                      ),

                      // 3. Categories Section
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

                      // 4. Daily Picks Section Title & Multi-Page Dots Indicator
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
                                    'Tap below to refresh fresh vertical wallpapers',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                    ),
                                    onPressed: () {
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
        ),
      ),
    );
  }
}
