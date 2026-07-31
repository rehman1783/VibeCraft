import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/unsplash_topic_model.dart';
import '../models/unsplash_wallpaper_model.dart';

abstract class UnsplashRemoteDataSource {
  Future<List<UnsplashWallpaperModel>> getCuratedPhotos({
    required int page,
    int perPage = 20,
    String? orderBy,
  });

  Future<List<UnsplashWallpaperModel>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
    String? orderBy,
    String? orientation,
    String? color,
  });

  Future<List<UnsplashTopicModel>> getTopics({
    int page = 1,
    int perPage = 20,
  });

  Future<List<UnsplashWallpaperModel>> getTopicPhotos({
    required String topicSlug,
    required int page,
    int perPage = 20,
    String? orientation,
  });

  Future<void> triggerDownloadLocation(String downloadLocationUrl);
}

class UnsplashRemoteDataSourceImpl implements UnsplashRemoteDataSource {
  final Dio dio;

  UnsplashRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UnsplashWallpaperModel>> getCuratedPhotos({
    required int page,
    int perPage = 20,
    String? orderBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (orderBy != null && orderBy.isNotEmpty) {
        queryParams['order_by'] = orderBy;
      }

      final response = await dio.get(
        '${AppConfig.unsplashBaseUrl}/photos',
        queryParameters: queryParams,
        options: Options(headers: AppConfig.unsplashHeaders),
      );

      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data
            .map((item) =>
                UnsplashWallpaperModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<UnsplashWallpaperModel>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
    String? orderBy,
    String? orientation,
    String? color,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query,
        'page': page,
        'per_page': perPage,
      };
      if (orderBy != null && orderBy.isNotEmpty) {
        queryParams['order_by'] = orderBy;
      }
      if (orientation != null && orientation.isNotEmpty) {
        queryParams['orientation'] = orientation;
      }
      if (color != null && color.isNotEmpty) {
        queryParams['color'] = color;
      }

      final response = await dio.get(
        '${AppConfig.unsplashBaseUrl}/search/photos',
        queryParameters: queryParams,
        options: Options(headers: AppConfig.unsplashHeaders),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List results = data['results'] as List? ?? [];
        return results
            .map((item) =>
                UnsplashWallpaperModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<UnsplashTopicModel>> getTopics({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.unsplashBaseUrl}/topics',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'order_by': 'featured',
        },
        options: Options(headers: AppConfig.unsplashHeaders),
      );

      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data
            .map((item) =>
                UnsplashTopicModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<UnsplashWallpaperModel>> getTopicPhotos({
    required String topicSlug,
    required int page,
    int perPage = 20,
    String? orientation,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (orientation != null && orientation.isNotEmpty) {
        queryParams['orientation'] = orientation;
      }

      final response = await dio.get(
        '${AppConfig.unsplashBaseUrl}/topics/$topicSlug/photos',
        queryParameters: queryParams,
        options: Options(headers: AppConfig.unsplashHeaders),
      );

      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data
            .map((item) =>
                UnsplashWallpaperModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> triggerDownloadLocation(String downloadLocationUrl) async {
    if (downloadLocationUrl.isEmpty) return;
    try {
      await dio.get(
        downloadLocationUrl,
        options: Options(headers: AppConfig.unsplashHeaders),
      );
    } catch (_) {
      // Non-blocking tracking request per Unsplash API guidelines
    }
  }
}
