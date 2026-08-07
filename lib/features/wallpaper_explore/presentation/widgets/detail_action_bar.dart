import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/entities/wallpaper_entity.dart';

class DetailActionBar extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onBackTap;
  final VoidCallback? onPreviewTap;

  const DetailActionBar({
    super.key,
    required this.wallpaper,
    required this.onBackTap,
    this.onPreviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          radius: 20,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: onBackTap,
          ),
        ),

        Row(
          children: [
            if (onPreviewTap != null) ...[
              CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                radius: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: onPreviewTap,
                ),
              ),
              const SizedBox(width: 10),
            ],

            // Interactive Heart / Favorite Icon Button
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                final isFav = context.read<FavoritesCubit>().isFavorite(wallpaper.id);

                return CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  radius: 20,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                    onPressed: () async {
                      final isNowFav = await context
                          .read<FavoritesCubit>()
                          .toggleFavorite(wallpaper);
                      if (context.mounted) {
                        if (isNowFav) {
                          AppSnackBar.showSuccess(context, 'Added to Favorites');
                        } else {
                          AppSnackBar.showInfo(context, 'Removed from Favorites');
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}