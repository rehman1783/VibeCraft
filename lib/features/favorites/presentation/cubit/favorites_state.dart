import '../../../wallpaper_explore/domain/entities/wallpaper_entity.dart';

class FavoritesState {
  final List<WallpaperEntity> favorites;
  final Set<String> favoriteIds;
  final bool isLoading;

  const FavoritesState({
    this.favorites = const [],
    this.favoriteIds = const {},
    this.isLoading = false,
  });

  FavoritesState copyWith({
    List<WallpaperEntity>? favorites,
    Set<String>? favoriteIds,
    bool? isLoading,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
