import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../routes.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../wallpaper_explore/domain/entities/wallpaper_entity.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_state.dart';
import '../widgets/downloads_toggle_switch.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isDownloadedSelected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WallpaperCubit>().loadDownloadedWallpapers();
      context.read<FavoritesCubit>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<WallpaperCubit, WallpaperState>(
          builder: (context, wallpaperState) {
            final downloadedList = wallpaperState.downloadedWallpapers;

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                final favoritesList = favState.favorites;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        'My Collection',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    // Toggle switch
                    DownloadsToggleSwitch(
                      isDownloadedSelected: _isDownloadedSelected,
                      onToggle: (isDownloaded) {
                        setState(() => _isDownloadedSelected = isDownloaded);
                      },
                    ),

                    // Grid or Empty State
                    Expanded(
                      child: _isDownloadedSelected
                          ? (downloadedList.isEmpty
                                ? _buildEmptyState(
                                    secondaryTextColor,
                                    'No downloads yet',
                                    'Your downloaded wallpapers will appear here',
                                    Icons.download_outlined,
                                  )
                                : _buildGrid(
                                    downloadedList,
                                    isDark,
                                    secondaryTextColor,
                                  ))
                          : (favoritesList.isEmpty
                                ? _buildEmptyState(
                                    secondaryTextColor,
                                    'No favorites yet',
                                    'Tap the heart icon on wallpapers to save favorites',
                                    Icons.favorite_outline_rounded,
                                  )
                                : _buildGrid(
                                    favoritesList,
                                    isDark,
                                    secondaryTextColor,
                                    isFavoritesTab: true,
                                  )),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    Color secondaryTextColor,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 72,
            color: secondaryTextColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: secondaryTextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<WallpaperEntity> items,
    bool isDark,
    Color secondaryTextColor, {
    bool isFavoritesTab = false,
  }) {
    final itemBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final itemBorder = isDark ? null : Border.all(color: AppColors.lightBorder);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isLocalFile =
              !item.highResUrl.startsWith('http') &&
              File(item.highResUrl).existsSync();

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.detail, arguments: item);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: itemBg,
                  border: itemBorder,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          isLocalFile
                              ? Image.file(
                                  File(item.highResUrl),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : CachedNetworkImage(
                                  imageUrl: item.thumbnailUrl.isNotEmpty
                                      ? item.thumbnailUrl
                                      : item.highResUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image_rounded,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),

                          // Heart toggle button on top right
                          Positioned(
                            top: 8,
                            right: 8,
                            child: BlocBuilder<FavoritesCubit, FavoritesState>(
                              builder: (context, favState) {
                                final isFav = context
                                    .read<FavoritesCubit>()
                                    .isFavorite(item.id);

                                return GestureDetector(
                                  onTap: () async {
                                    final isNowFav = await context
                                        .read<FavoritesCubit>()
                                        .toggleFavorite(item);
                                    if (context.mounted) {
                                      if (isNowFav) {
                                        AppSnackBar.showSuccess(
                                          context,
                                          'Added to Favorites',
                                        );
                                      } else {
                                        AppSnackBar.showInfo(
                                          context,
                                          'Removed from Favorites',
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isFav
                                          ? Colors.redAccent
                                          : Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.photographer,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isLocalFile
                                      ? AppColors.primary.withValues(
                                          alpha: 0.15,
                                        )
                                      : Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isLocalFile ? 'Downloaded' : 'Online',
                                  style: TextStyle(
                                    color: isLocalFile
                                        ? AppColors.primary
                                        : Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
