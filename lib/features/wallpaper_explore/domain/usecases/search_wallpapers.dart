import '../entities/wallpaper_entity.dart';
import '../repositories/wallpaper_repository.dart';

class SearchWallpapers {
  final WallpaperRepository repository;

  SearchWallpapers(this.repository);

  Future<List<WallpaperEntity>> call(String query, int page) async {
    // Business rule: Prevent empty queries from hitting the backend
    if (query.trim().isEmpty) {
      return [];
    }
    return await repository.searchWallpapers(query: query, page: page);
  }
}