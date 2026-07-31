import '../../../wallpaper_explore/domain/entities/wallpaper_entity.dart';

abstract class FavoritesRepository {
  Future<List<WallpaperEntity>> getFavoriteWallpapers();
  Future<bool> isFavorite(String wallpaperId);
  Future<bool> toggleFavorite(WallpaperEntity wallpaper);
  Future<void> updateFavoriteLocalPath(String wallpaperId, String localPath);
  Future<void> sanitizeFavoritesAfterCacheClear();
}
