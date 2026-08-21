import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/entities/wallpaper_entity.dart';

/// Redesigned tall portrait-oriented wallpaper preview card.
/// Features rounded corners, category overlay at bottom-left,
/// and a heart icon integrated within a dark translucent circular overlay at bottom-right.
class WallpaperCard extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
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

    // Display photographer name like Explore screen wallpapers
    final String titleText = wallpaper.photographer.trim().isNotEmpty
        ? wallpaper.photographer.trim()
        : 'VibeCraft';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: cardBgColor ?? (isDark ? AppColors.surface : AppColors.lightSurface),
            child: AspectRatio(
              aspectRatio: 0.68, // Tall portrait aspect ratio
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

                  // Bottom Gradient Shadow overlay for text readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.black.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  // Full Wallpaper Title Text Overlay at Bottom-Left
                  Positioned(
                    left: 12,
                    bottom: 12,
                    right: 48,
                    child: Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Subtly Integrated Heart Icon inside Dark Translucent Overlay at Bottom-Right
                  Positioned(
                    right: 10,
                    bottom: 10,
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
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
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