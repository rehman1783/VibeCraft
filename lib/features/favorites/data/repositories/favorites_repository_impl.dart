import '../datasources/favorites_local_data_source.dart';
import '../../../wallpaper_explore/domain/entities/wallpaper_entity.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<WallpaperEntity>> getFavoriteWallpapers() async {
    return await localDataSource.getFavoriteWallpapers();
  }

  @override
  Future<bool> isFavorite(String wallpaperId) async {
    return await localDataSource.isFavorite(wallpaperId);
  }

  @override
  Future<bool> toggleFavorite(WallpaperEntity wallpaper) async {
    return await localDataSource.toggleFavorite(wallpaper);
  }

  @override
  Future<void> updateFavoriteLocalPath(String wallpaperId, String localPath) async {
    await localDataSource.updateFavoriteLocalPath(wallpaperId, localPath);
  }

  @override
  Future<void> sanitizeFavoritesAfterCacheClear() async {
    await localDataSource.sanitizeFavoritesAfterCacheClear();
  }
}
