import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/content_safety_filter.dart';
import '../models/pixabay_wallpaper_model.dart';

abstract class PixabayRemoteDataSource {
  Future<List<PixabayWallpaperModel>> getCuratedPhotos({
    required int page,
    int perPage = 20,
    String? orderBy,
  });

  Future<List<PixabayWallpaperModel>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
    String? orderBy,
    String? orientation,
    String? color,
    String? category,
  });
}

class PixabayRemoteDataSourceImpl implements PixabayRemoteDataSource {
  final Dio dio;

  PixabayRemoteDataSourceImpl({required this.dio});

  String _mapOrientation(String? orientation) {
    if (orientation == null || orientation.isEmpty) return 'vertical';
    switch (orientation.toLowerCase()) {
      case 'portrait':
      case 'vertical':
        return 'vertical';
      case 'landscape':
      case 'horizontal':
        return 'horizontal';
      case 'squarish':
      case 'all':
      default:
        return 'all';
    }
  }

  String? _mapColor(String? color) {
    if (color == null || color.isEmpty) return null;
    switch (color.toLowerCase()) {
      case 'black_and_white':
        return 'grayscale';
      case 'black':
        return 'black';
      case 'white':
        return 'white';
      case 'red':
        return 'red';
      case 'blue':
        return 'blue';
      case 'green':
        return 'green';
      case 'yellow':
        return 'yellow';
      case 'orange':
        return 'orange';
      case 'purple':
        return 'lilac';
      case 'teal':
        return 'turquoise';
      default:
        return color;
    }
  }

  String _mapOrder(String? orderBy) {
    if (orderBy == null || orderBy.isEmpty) return 'popular';
    switch (orderBy.toLowerCase()) {
      case 'latest':
        return 'latest';
      case 'popular':
      case 'relevant':
      default:
        return 'popular';
    }
  }

  @override
  Future<List<PixabayWallpaperModel>> getCuratedPhotos({
    required int page,
    int perPage = 20,
    String? orderBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'key': AppConfig.pixabayApiKey,
        'q': 'wallpapers',
        'image_type': 'photo',
        'orientation': 'vertical',
        'order': _mapOrder(orderBy),
        'editors_choice': 'true',
        'safesearch': 'true',
        'page': page,
        'per_page': perPage,
      };

      final response = await dio.get(
        AppConfig.pixabayBaseUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List hits = data['hits'] as List? ?? [];
        return hits
            .map((item) =>
                PixabayWallpaperModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<PixabayWallpaperModel>> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
    String? orderBy,
    String? orientation,
    String? color,
    String? category,
  }) async {
    try {
      final safeQuery = SafeContentFilter.sanitizeSearchQuery(query);
      final effectiveQuery = safeQuery.isNotEmpty ? safeQuery : 'wallpapers';
      final mappedOrientation = _mapOrientation(orientation);
      final mappedColor = _mapColor(color);
      final mappedOrder = _mapOrder(orderBy);

      final queryParams = <String, dynamic>{
        'key': AppConfig.pixabayApiKey,
        'q': effectiveQuery,
        'image_type': 'photo',
        'orientation': mappedOrientation,
        'order': mappedOrder,
        'safesearch': 'true',
        'page': page,
        'per_page': perPage,
      };

      if (mappedColor != null && mappedColor.isNotEmpty) {
        queryParams['colors'] = mappedColor;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category.toLowerCase();
      }

      final response = await dio.get(
        AppConfig.pixabayBaseUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List hits = data['hits'] as List? ?? [];
        return hits
            .map((item) =>
                PixabayWallpaperModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
