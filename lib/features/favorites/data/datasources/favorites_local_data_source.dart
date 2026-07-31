import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_craft/features/wallpaper_explore/domain/entities/wallpaper_entity.dart';

abstract class FavoritesLocalDataSource {
  Future<List<WallpaperEntity>> getFavoriteWallpapers();
  Future<bool> isFavorite(String wallpaperId);
  Future<bool> toggleFavorite(WallpaperEntity wallpaper);
  Future<void> updateFavoriteLocalPath(String wallpaperId, String localPath);
  Future<void> sanitizeFavoritesAfterCacheClear();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _favoritesKey = 'VibeCraft_FAVORITE_WALLPAPERS';
  static const String _downloadedKey = 'VibeCraft_DOWNLOADED_WALLPAPERS';

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<WallpaperEntity>> getFavoriteWallpapers() async {
    final jsonList = sharedPreferences.getStringList(_favoritesKey) ?? [];
    final list = jsonList
        .map(
          (str) =>
              WallpaperEntity.fromJson(jsonDecode(str) as Map<String, dynamic>),
        )
        .toList();

    // Verify local file paths: if local file was deleted or pruned, fallback to raw/thumbnail URL
    bool needsSave = false;
    final List<WallpaperEntity> sanitizedList = list.map((WallpaperEntity w) {
      if (!w.highResUrl.startsWith('http') &&
          !File(w.highResUrl).existsSync()) {
        needsSave = true;
        final fallbackUrl = w.rawUrl.isNotEmpty ? w.rawUrl : w.thumbnailUrl;
        return WallpaperEntity(
          id: w.id,
          thumbnailUrl: w.thumbnailUrl,
          highResUrl: fallbackUrl,
          rawUrl: w.rawUrl,
          photographer: w.photographer,
          photographerUsername: w.photographerUsername,
          altDescription: w.altDescription,
          downloadLocation: w.downloadLocation,
          color: w.color,
          likes: w.likes,
          width: w.width,
          height: w.height,
        );
      }
      return w;
    }).toList();

    if (needsSave) {
      final updatedJsonList = sanitizedList
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await sharedPreferences.setStringList(_favoritesKey, updatedJsonList);
    }

    return sanitizedList;
  }

  @override
  Future<bool> isFavorite(String wallpaperId) async {
    final favorites = await getFavoriteWallpapers();
    return favorites.any((w) => w.id == wallpaperId);
  }

  @override
  Future<bool> toggleFavorite(WallpaperEntity wallpaper) async {
    final favorites = await getFavoriteWallpapers();
    final index = favorites.indexWhere((w) => w.id == wallpaper.id);

    bool isNowFavorite = false;
    if (index >= 0) {
      favorites.removeAt(index);
      isNowFavorite = false;
    } else {
      // Check if wallpaper is already downloaded locally
      final downloadedJson =
          sharedPreferences.getStringList(_downloadedKey) ?? [];
      final List<WallpaperEntity> downloadedList = downloadedJson
          .map(
            (str) => WallpaperEntity.fromJson(
              jsonDecode(str) as Map<String, dynamic>,
            ),
          )
          .toList();

      final WallpaperEntity downloadedMatch = downloadedList.firstWhere(
        (d) => d.id == wallpaper.id && File(d.highResUrl).existsSync(),
        orElse: () => wallpaper,
      );

      favorites.insert(0, downloadedMatch);
      isNowFavorite = true;
    }

    final jsonList = favorites
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await sharedPreferences.setStringList(_favoritesKey, jsonList);
    return isNowFavorite;
  }

  @override
  Future<void> updateFavoriteLocalPath(
    String wallpaperId,
    String localPath,
  ) async {
    final favorites = await getFavoriteWallpapers();
    final index = favorites.indexWhere((w) => w.id == wallpaperId);
    if (index >= 0) {
      final old = favorites[index];
      final updated = WallpaperEntity(
        id: old.id,
        thumbnailUrl: old.thumbnailUrl,
        highResUrl: localPath,
        rawUrl: old.rawUrl,
        photographer: old.photographer,
        photographerUsername: old.photographerUsername,
        altDescription: old.altDescription,
        downloadLocation: old.downloadLocation,
        color: old.color,
        likes: old.likes,
        width: old.width,
        height: old.height,
      );
      favorites[index] = updated;
      final jsonList = favorites
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await sharedPreferences.setStringList(_favoritesKey, jsonList);
    }
  }

  @override
  Future<void> sanitizeFavoritesAfterCacheClear() async {
    final favorites = await getFavoriteWallpapers();
    final List<WallpaperEntity> sanitizedList = favorites.map((
      WallpaperEntity w,
    ) {
      if (!w.highResUrl.startsWith('http')) {
        final fallbackUrl = w.rawUrl.isNotEmpty ? w.rawUrl : w.thumbnailUrl;
        return WallpaperEntity(
          id: w.id,
          thumbnailUrl: w.thumbnailUrl,
          highResUrl: fallbackUrl,
          rawUrl: w.rawUrl,
          photographer: w.photographer,
          photographerUsername: w.photographerUsername,
          altDescription: w.altDescription,
          downloadLocation: w.downloadLocation,
          color: w.color,
          likes: w.likes,
          width: w.width,
          height: w.height,
        );
      }
      return w;
    }).toList();

    final jsonList = sanitizedList
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await sharedPreferences.setStringList(_favoritesKey, jsonList);
  }
}
