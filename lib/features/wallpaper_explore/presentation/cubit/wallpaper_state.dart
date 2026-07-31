import '../../data/models/unsplash_topic_model.dart';
import '../../domain/entities/wallpaper_entity.dart';

enum WallpaperStatus { initial, loading, loaded, failure }
enum WallpaperDownloadStatus { initial, downloading, downloaded, failure }
enum WallpaperApplyStatus { initial, applying, success, failure }

class WallpaperState {
  final WallpaperStatus status;
  final List<WallpaperEntity> wallpapers;
  final int page;
  final bool hasReachedMax;
  final String? currentQuery;
  final String? selectedCategory;
  final String? selectedOrientation; // portrait, landscape, squarish
  final String? selectedColor; // black_and_white, black, white, red, blue, green, etc.
  final String selectedSort; // popular, latest, relevant
  final List<UnsplashTopicModel> topics;
  final WallpaperDownloadStatus downloadStatus;
  final Set<String> downloadingIds;
  final String? lastDownloadedId;
  final String? lastFailedId;
  final String? downloadedFilePath;
  final WallpaperApplyStatus applyStatus;
  final String? errorMessage;
  final List<WallpaperEntity> downloadedWallpapers;
  final List<String> recentSearches;

  const WallpaperState({
    this.status = WallpaperStatus.initial,
    this.wallpapers = const [],
    this.page = 1,
    this.hasReachedMax = false,
    this.currentQuery,
    this.selectedCategory,
    this.selectedOrientation,
    this.selectedColor,
    this.selectedSort = 'popular',
    this.topics = const [],
    this.downloadStatus = WallpaperDownloadStatus.initial,
    this.downloadingIds = const {},
    this.lastDownloadedId,
    this.lastFailedId,
    this.downloadedFilePath,
    this.applyStatus = WallpaperApplyStatus.initial,
    this.errorMessage,
    this.downloadedWallpapers = const [],
    this.recentSearches = const [],
  });

  bool isDownloading(String wallpaperId) => downloadingIds.contains(wallpaperId);

  WallpaperState copyWith({
    WallpaperStatus? status,
    List<WallpaperEntity>? wallpapers,
    int? page,
    bool? hasReachedMax,
    String? currentQuery,
    bool clearQuery = false,
    String? selectedCategory,
    bool clearCategory = false,
    String? selectedOrientation,
    bool clearOrientation = false,
    String? selectedColor,
    bool clearColor = false,
    String? selectedSort,
    List<UnsplashTopicModel>? topics,
    WallpaperDownloadStatus? downloadStatus,
    Set<String>? downloadingIds,
    String? lastDownloadedId,
    bool clearLastDownloadedId = false,
    String? lastFailedId,
    bool clearLastFailedId = false,
    String? downloadedFilePath,
    WallpaperApplyStatus? applyStatus,
    String? errorMessage,
    List<WallpaperEntity>? downloadedWallpapers,
    List<String>? recentSearches,
  }) {
    return WallpaperState(
      status: status ?? this.status,
      wallpapers: wallpapers ?? this.wallpapers,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentQuery: clearQuery ? null : (currentQuery ?? this.currentQuery),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedOrientation: clearOrientation ? null : (selectedOrientation ?? this.selectedOrientation),
      selectedColor: clearColor ? null : (selectedColor ?? this.selectedColor),
      selectedSort: selectedSort ?? this.selectedSort,
      topics: topics ?? this.topics,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadingIds: downloadingIds ?? this.downloadingIds,
      lastDownloadedId: clearLastDownloadedId ? null : (lastDownloadedId ?? this.lastDownloadedId),
      lastFailedId: clearLastFailedId ? null : (lastFailedId ?? this.lastFailedId),
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      applyStatus: applyStatus ?? this.applyStatus,
      errorMessage: errorMessage,
      downloadedWallpapers: downloadedWallpapers ?? this.downloadedWallpapers,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}