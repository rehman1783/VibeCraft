import '../entities/wallpaper_entity.dart';
import '../../data/models/unsplash_topic_model.dart';

enum WallpaperTarget { home, lock, both }

abstract class WallpaperRepository {
  Future<List<WallpaperEntity>> getCuratedWallpapers({
    required int page,
    String? orderBy,
    String? source,
  });

  Future<List<WallpaperEntity>> searchWallpapers({
    required String query,
    required int page,
    String? orderBy,
    String? orientation,
    String? color,
    String? source,
  });

  Future<List<UnsplashTopicModel>> getTopics();

  Future<List<WallpaperEntity>> getTopicWallpapers({
    required String topicSlug,
    required int page,
    String? orientation,
  });

  Future<String> downloadWallpaper(WallpaperEntity wallpaper);

  Future<List<WallpaperEntity>> getDownloadedWallpapers();

  Future<bool> isWallpaperDownloaded(String wallpaperId);

  Future<bool> applyWallpaper({
    required String imagePathOrUrl,
    required WallpaperTarget target,
  });

  Future<void> clearAllDownloadedWallpapers();
}