import '../entities/wallpaper_entity.dart';
import '../repositories/wallpaper_repository.dart';

class GetTrendingWallpapers {
  final WallpaperRepository repository;

  GetTrendingWallpapers(this.repository);

  /// Invokes the usecase. [page] handles pagination logic.
  Future<List<WallpaperEntity>> call(int page) async {
    return await repository.getCuratedWallpapers(page: page);
  }
}