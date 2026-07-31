import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/entities/wallpaper_entity.dart';

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

    final isLocalFile = !wallpaper.highResUrl.startsWith('http') && File(wallpaper.highResUrl).existsSync();

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: cardBgColor ?? (isDark ? AppColors.surface : AppColors.lightSurface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  isLocalFile
                      ? Image.file(
                          File(wallpaper.highResUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : CachedNetworkImage(
                          imageUrl: wallpaper.thumbnailUrl.isNotEmpty
                              ? wallpaper.thumbnailUrl
                              : wallpaper.highResUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: cardBgColor ?? (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        ),

                  // Floating Interactive Heart / Favorite Icon Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFav = context.read<FavoritesCubit>().isFavorite(wallpaper.id);

                        return GestureDetector(
                          onTap: () async {
                            final isNowFav = await context
                                .read<FavoritesCubit>()
                                .toggleFavorite(wallpaper);
                            if (context.mounted) {
                              if (isNowFav) {
                                AppSnackBar.showSuccess(context, 'Added to Favorites! ❤️');
                              } else {
                                AppSnackBar.showInfo(context, 'Removed from Favorites.');
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallpaper.photographer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    if (wallpaper.likes > 0) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${wallpaper.likes}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}