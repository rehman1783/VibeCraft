import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/entities/wallpaper_entity.dart';

/// Staggered masonry wallpaper card designed specifically for the Explore Screen.
/// Features dynamic aspect ratios, rounded corners, subtle bottom gradient overlay
/// displaying photographer name, likes/downloads count, and a quick action favorite button.
class ExploreWallpaperCard extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final int index;
  final VoidCallback onTap;

  const ExploreWallpaperCard({
    super.key,
    required this.wallpaper,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color? cardBgColor;
    if (wallpaper.color != null && wallpaper.color!.startsWith('#')) {
      try {
        final hexStr = wallpaper.color!.replaceFirst('#', '');
        cardBgColor = Color(int.parse('FF$hexStr', radix: 16)).withValues(alpha: 0.3);
      } catch (_) {}
    }

    final isLocalFile = !wallpaper.highResUrl.startsWith('http') &&
        File(wallpaper.highResUrl).existsSync();

    // Uniform phone wallpaper aspect ratio for clean visual consistency
    const double aspectRatio = 0.68;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            color: cardBgColor ?? (isDark ? AppColors.surface : AppColors.lightSurface),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Wallpaper Image
                  isLocalFile
                      ? Image.file(
                          File(wallpaper.highResUrl),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: wallpaper.thumbnailUrl.isNotEmpty
                              ? wallpaper.thumbnailUrl
                              : wallpaper.highResUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: cardBgColor ??
                                (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          ),
                        ),

                  // Top-Left Source Badge (Unsplash / Pixabay)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            wallpaper.source.toLowerCase() == 'pixabay'
                                ? Icons.palette_outlined
                                : Icons.camera_alt_outlined,
                            size: 10,
                            color: wallpaper.source.toLowerCase() == 'pixabay'
                                ? AppColors.electricBlue
                                : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            wallpaper.source,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Gradient Overlay for typography readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  // Photographer Name & Likes / Downloads Info at Bottom-Left
                  Positioned(
                    left: 10,
                    bottom: 10,
                    right: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wallpaper.photographer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${wallpaper.likes}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Favorite Button at Bottom-Right
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFav =
                            context.read<FavoritesCubit>().isFavorite(wallpaper.id);

                        return GestureDetector(
                          onTap: () async {
                            final isNowFav = await context
                                .read<FavoritesCubit>()
                                .toggleFavorite(wallpaper);
                            if (context.mounted) {
                              if (isNowFav) {
                                AppSnackBar.showSuccess(
                                    context, 'Added to Favorites! ❤️');
                              } else {
                                AppSnackBar.showInfo(
                                    context, 'Removed from Favorites.');
                              }
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav ? Colors.redAccent : Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
