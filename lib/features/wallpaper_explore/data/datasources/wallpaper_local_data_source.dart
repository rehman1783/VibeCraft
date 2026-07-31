import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/wallpaper_entity.dart';

abstract class WallpaperLocalDataSource {
  Future<String> saveWallpaperToStorage(WallpaperEntity wallpaper);
  Future<List<WallpaperEntity>> getDownloadedWallpapers();
  Future<bool> isWallpaperDownloaded(String wallpaperId);
  Future<void> clearAllDownloadedWallpapers();
}

class WallpaperLocalDataSourceImpl implements WallpaperLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Dio dio;
  static const String _downloadedKey = 'WALLZEN_DOWNLOADED_WALLPAPERS';
  static const int _maxStorageCapBytes = 100 * 1024 * 1024; // 100 MB Limit

  WallpaperLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.dio,
  });

  Future<Directory> _getWallpapersDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final wallpapersDir = Directory('${appDir.path}/wallpapers');
    if (!await wallpapersDir.exists()) {
      await wallpapersDir.create(recursive: true);
    }
    return wallpapersDir;
  }

  @override
  Future<String> saveWallpaperToStorage(WallpaperEntity wallpaper) async {
    final wallDir = await _getWallpapersDirectory();
    final fileName = 'wallzen_${wallpaper.id}.jpg';
    final filePath = '${wallDir.path}/$fileName';
    final file = File(filePath);

    final downloadUrl = wallpaper.highResUrl.isNotEmpty
        ? wallpaper.highResUrl
        : wallpaper.thumbnailUrl;

    final response = await dio.get(
      downloadUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    await file.writeAsBytes(response.data as List<int>);

    // Persist wallpaper entity metadata locally
    final existingList = await getDownloadedWallpapers();
    final updatedList = existingList.where((w) => w.id != wallpaper.id).toList();

    final savedEntity = WallpaperEntity(
      id: wallpaper.id,
      thumbnailUrl: wallpaper.thumbnailUrl,
      highResUrl: filePath,
      rawUrl: wallpaper.rawUrl,
      photographer: wallpaper.photographer,
      photographerUsername: wallpaper.photographerUsername,
      altDescription: wallpaper.altDescription,
      downloadLocation: wallpaper.downloadLocation,
      color: wallpaper.color,
      likes: wallpaper.likes,
      width: wallpaper.width,
      height: wallpaper.height,
    );

    // Newest download inserted at top
    updatedList.insert(0, savedEntity);

    final jsonList = updatedList.map((item) => jsonEncode(item.toJson())).toList();
    await sharedPreferences.setStringList(_downloadedKey, jsonList);

    // Enforce 100MB auto-pruning (FIFO)
    await _enforce100MBStorageCap(wallDir);

    return filePath;
  }

  @override
  Future<List<WallpaperEntity>> getDownloadedWallpapers() async {
    final jsonList = sharedPreferences.getStringList(_downloadedKey) ?? [];
    final list = jsonList
        .map((str) => WallpaperEntity.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
    
    // Filter out files that might have been manually removed
    return list.where((w) {
      if (!w.highResUrl.startsWith('http')) {
        return File(w.highResUrl).existsSync();
      }
      return true;
    }).toList();
  }

  @override
  Future<bool> isWallpaperDownloaded(String wallpaperId) async {
    final wallpapers = await getDownloadedWallpapers();
    return wallpapers.any((element) => element.id == wallpaperId);
  }

  @override
  Future<void> clearAllDownloadedWallpapers() async {
    try {
      final wallDir = await _getWallpapersDirectory();
      if (await wallDir.exists()) {
        final entities = wallDir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (_) {}
    await sharedPreferences.remove(_downloadedKey);
  }

  /// Calculates current total disk usage of wallpapers folder and auto-purges oldest entries if > 100MB
  Future<void> _enforce100MBStorageCap(Directory wallDir) async {
    int currentSize = await _calculateDirectorySize(wallDir);

    if (currentSize <= _maxStorageCapBytes) return;

    final list = await getDownloadedWallpapers();

    // FIFO Purging: oldest items are at the end of the list
    while (currentSize > _maxStorageCapBytes && list.isNotEmpty) {
      final oldestItem = list.removeLast();
      final file = File(oldestItem.highResUrl);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      currentSize = await _calculateDirectorySize(wallDir);
    }

    final jsonList = list.map((item) => jsonEncode(item.toJson())).toList();
    await sharedPreferences.setStringList(_downloadedKey, jsonList);
  }

  Future<int> _calculateDirectorySize(Directory dir) async {
    int size = 0;
    if (await dir.exists()) {
      final files = dir.listSync();
      for (final file in files) {
        if (file is File) {
          size += await file.length();
        }
      }
    }
    return size;
  }
}
