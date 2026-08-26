import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/wallpaper_service.dart';
import '../../../../core/utils/content_safety_filter.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/pixabay_remote_source.dart';
import '../datasources/unsplash_remote_source.dart';
import '../datasources/wallpaper_local_data_source.dart';
import '../models/unsplash_topic_model.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final UnsplashRemoteDataSource unsplashRemoteDataSource;
  final PixabayRemoteDataSource pixabayRemoteDataSource;
  final WallpaperLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final WallpaperService wallpaperService;

  WallpaperRepositoryImpl({
    required this.unsplashRemoteDataSource,
    required this.pixabayRemoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.wallpaperService,
  });

  List<WallpaperEntity> _interleave(
    List<WallpaperEntity> unsplashList,
    List<WallpaperEntity> pixabayList,
  ) {
    if (unsplashList.isEmpty) return pixabayList;
    if (pixabayList.isEmpty) return unsplashList;

    final result = <WallpaperEntity>[];
    int u = 0;
    int p = 0;

    // Prioritize Unsplash (2 Unsplash items for every 1 Pixabay item)
    while (u < unsplashList.length || p < pixabayList.length) {
      if (u < unsplashList.length) {
        result.add(unsplashList[u++]);
      }
      if (u < unsplashList.length) {
        result.add(unsplashList[u++]);
      }
      if (p < pixabayList.length) {
        result.add(pixabayList[p++]);
      }
    }
    return result;
  }

  @override
  Future<List<WallpaperEntity>> getCuratedWallpapers({
    required int page,
    String? orderBy,
    String? source,
  }) async {
    if (!await networkInfo.isConnected) {
      throw const NoInternetFailure();
    }

    final selectedSource = source?.toLowerCase() ?? 'all';

    if (selectedSource == 'unsplash') {
      try {
        final models = await unsplashRemoteDataSource
            .getCuratedPhotos(page: page, orderBy: orderBy)
            .timeout(const Duration(seconds: 12));
        final list = models.map((m) => m.toEntity()).toList();
        final safeList = SafeContentFilter.filterWallpapers(list);
        if (safeList.isNotEmpty) return safeList;
      } catch (_) {
        // Fallback to Pixabay if Unsplash encounters rate-limits or errors
      }
      try {
        final models = await pixabayRemoteDataSource
            .getCuratedPhotos(page: page, orderBy: orderBy)
            .timeout(const Duration(seconds: 12));
        return SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
      } catch (e) {
        throw ServerFailure(message: e.toString());
      }
    }

    if (selectedSource == 'pixabay') {
      try {
        final models = await pixabayRemoteDataSource
            .getCuratedPhotos(page: page, orderBy: orderBy)
            .timeout(const Duration(seconds: 12));
        final list = models.map((m) => m.toEntity()).toList();
        final safeList = SafeContentFilter.filterWallpapers(list);
        if (safeList.isNotEmpty) return safeList;
      } catch (_) {
        // Fallback to Unsplash if Pixabay fails
      }
      try {
        final models = await unsplashRemoteDataSource
            .getCuratedPhotos(page: page, orderBy: orderBy)
            .timeout(const Duration(seconds: 12));
        return SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
      } catch (e) {
        throw ServerFailure(message: e.toString());
      }
    }

    // Default: Aggregate both Unsplash & Pixabay concurrently with resilient error isolation
    List<WallpaperEntity> unsplashResults = [];
    List<WallpaperEntity> pixabayResults = [];
    Object? lastError;

    await Future.wait([
      (() async {
        try {
          final models = await unsplashRemoteDataSource
              .getCuratedPhotos(page: page, orderBy: orderBy)
              .timeout(const Duration(seconds: 12));
          unsplashResults = SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
        } catch (e) {
          lastError = e;
        }
      })(),
      (() async {
        try {
          final models = await pixabayRemoteDataSource
              .getCuratedPhotos(page: page, orderBy: orderBy)
              .timeout(const Duration(seconds: 12));
          pixabayResults = SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
        } catch (e) {
          lastError = e;
        }
      })(),
    ]);

    if (unsplashResults.isEmpty && pixabayResults.isEmpty && lastError != null) {
      throw ServerFailure(message: lastError.toString());
    }

    return _interleave(unsplashResults, pixabayResults);
  }

  @override
  Future<List<WallpaperEntity>> searchWallpapers({
    required String query,
    required int page,
    String? orderBy,
    String? orientation,
    String? color,
    String? source,
  }) async {
    if (!await networkInfo.isConnected) {
      throw const NoInternetFailure();
    }

    final safeQuery = SafeContentFilter.sanitizeSearchQuery(query);
    final selectedSource = source?.toLowerCase() ?? 'all';

    if (selectedSource == 'unsplash') {
      try {
        final models = await unsplashRemoteDataSource
            .searchPhotos(
              query: safeQuery,
              page: page,
              orderBy: orderBy,
              orientation: orientation,
              color: color,
            )
            .timeout(const Duration(seconds: 12));
        final list = models.map((m) => m.toEntity()).toList();
        final safeList = SafeContentFilter.filterWallpapers(list);
        if (safeList.isNotEmpty) return safeList;
      } catch (_) {
        // Fallback to Pixabay if Unsplash fails
      }
      try {
        final models = await pixabayRemoteDataSource
            .searchPhotos(
              query: safeQuery,
              page: page,
              orderBy: orderBy,
              orientation: orientation,
              color: color,
            )
            .timeout(const Duration(seconds: 12));
        return SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
      } catch (e) {
        throw ServerFailure(message: e.toString());
      }
    }

    if (selectedSource == 'pixabay') {
      try {
        final models = await pixabayRemoteDataSource
            .searchPhotos(
              query: safeQuery,
              page: page,
              orderBy: orderBy,
              orientation: orientation,
              color: color,
            )
            .timeout(const Duration(seconds: 12));
        final list = models.map((m) => m.toEntity()).toList();
        final safeList = SafeContentFilter.filterWallpapers(list);
        if (safeList.isNotEmpty) return safeList;
      } catch (_) {
        // Fallback to Unsplash if Pixabay fails
      }
      try {
        final models = await unsplashRemoteDataSource
            .searchPhotos(
              query: safeQuery,
              page: page,
              orderBy: orderBy,
              orientation: orientation,
              color: color,
            )
            .timeout(const Duration(seconds: 12));
        return SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
      } catch (e) {
        throw ServerFailure(message: e.toString());
      }
    }

    // Default: Aggregate both Unsplash & Pixabay concurrently with resilient error isolation
    List<WallpaperEntity> unsplashResults = [];
    List<WallpaperEntity> pixabayResults = [];
    Object? lastError;

    await Future.wait([
      (() async {
        try {
          final models = await unsplashRemoteDataSource
              .searchPhotos(
                query: safeQuery,
                page: page,
                orderBy: orderBy,
                orientation: orientation,
                color: color,
              )
              .timeout(const Duration(seconds: 12));
          unsplashResults = SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
        } catch (e) {
          lastError = e;
        }
      })(),
      (() async {
        try {
          final models = await pixabayRemoteDataSource
              .searchPhotos(
                query: safeQuery,
                page: page,
                orderBy: orderBy,
                orientation: orientation,
                color: color,
              )
              .timeout(const Duration(seconds: 12));
          pixabayResults = SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
        } catch (e) {
          lastError = e;
        }
      })(),
    ]);

    if (unsplashResults.isEmpty && pixabayResults.isEmpty && lastError != null) {
      throw ServerFailure(message: lastError.toString());
    }

    return _interleave(unsplashResults, pixabayResults);
  }

  @override
  Future<List<UnsplashTopicModel>> getTopics() async {
    if (!await networkInfo.isConnected) {
      return [];
    }
    try {
      return await unsplashRemoteDataSource.getTopics();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<WallpaperEntity>> getTopicWallpapers({
    required String topicSlug,
    required int page,
    String? orientation,
  }) async {
    if (!await networkInfo.isConnected) {
      throw const NoInternetFailure();
    }
    try {
      final models = await unsplashRemoteDataSource.getTopicPhotos(
        topicSlug: topicSlug,
        page: page,
        orientation: orientation,
      );
      return SafeContentFilter.filterWallpapers(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<String> downloadWallpaper(WallpaperEntity wallpaper) async {
    // 1. Trigger Unsplash API download_location endpoint per API guidelines
    if (wallpaper.downloadLocation.isNotEmpty) {
      await unsplashRemoteDataSource.triggerDownloadLocation(wallpaper.downloadLocation);
    }

    // 2. Download and save locally
    return await localDataSource.saveWallpaperToStorage(wallpaper);
  }

  @override
  Future<List<WallpaperEntity>> getDownloadedWallpapers() async {
    return await localDataSource.getDownloadedWallpapers();
  }

  @override
  Future<bool> isWallpaperDownloaded(String wallpaperId) async {
    return await localDataSource.isWallpaperDownloaded(wallpaperId);
  }

  @override
  Future<bool> applyWallpaper({
    required String imagePathOrUrl,
    required WallpaperTarget target,
  }) async {
    try {
      int targetInt;
      switch (target) {
        case WallpaperTarget.home:
          targetInt = WallpaperService.targetHome;
          break;
        case WallpaperTarget.lock:
          targetInt = WallpaperService.targetLock;
          break;
        case WallpaperTarget.both:
          targetInt = WallpaperService.targetBoth;
          break;
      }

      String localFilePath = imagePathOrUrl;

      // If the target is a remote URL, download it to temporary storage first
      if (imagePathOrUrl.startsWith('http://') || imagePathOrUrl.startsWith('https://')) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/temp_wall_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final dio = Dio();
        final response = await dio.get(
          imagePathOrUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final file = File(tempPath);
        await file.writeAsBytes(response.data as List<int>);
        localFilePath = tempPath;
      }

      final file = File(localFilePath);
      if (!await file.exists()) {
        throw const ServerFailure(message: 'Wallpaper file does not exist locally.');
      }

      return await wallpaperService.setWallpaper(
        filePath: localFilePath,
        target: targetInt,
      );
    } catch (e) {
      throw ServerFailure(message: 'Failed to set wallpaper: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllDownloadedWallpapers() async {
    await localDataSource.clearAllDownloadedWallpapers();
  }
}