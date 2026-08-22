import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../../../search/data/datasources/search_local_data_source.dart';
import '../widgets/category_selector_bar.dart';
import 'wallpaper_state.dart';

class WallpaperCubit extends Cubit<WallpaperState> {
  final WallpaperRepository repository;
  final SearchLocalDataSource searchLocalDataSource;

  // Curated diverse high-aesthetic themes for Daily Picks to ensure fresh, dynamic wallpapers
  static const List<String> _dailyPickThemes = [
    'aesthetic wallpaper 4k',
    'cinematic moody portrait',
    'minimalist amoled dark',
    'deep space galaxy nebula',
    'cyberpunk neon city night',
    'stunning nature landscape vertical',
    '3d abstract render fluid',
    'ocean waves aerial aesthetic',
    'dark atmospheric landscape',
    'modern architecture minimal',
    'vibrant anime aesthetic artwork',
    'clean gradient abstract art',
    'exotic supercars aesthetic',
    'lush green forest mist',
    'sunset golden hour aesthetic',
    'pastel dreamy artistic wallpaper',
    'synthwave retro 80s neon',
    'minimalist monochrome black',
    'epic mountain peaks foggy',
    'futuristic sci fi concept art',
  ];

  int _lastThemeIndex = -1;
  String? _currentDailyTheme;
  final Set<String> _seenWallpaperIds = <String>{};
  static const int _maxSeenHistory = 200;

  WallpaperCubit({
    required this.repository,
    required this.searchLocalDataSource,
  }) : super(const WallpaperState()) {
    loadRecentSearches();
  }

  Future<void> loadRecentSearches() async {
    try {
      final recent = await searchLocalDataSource.getRecentSearches();
      emit(state.copyWith(recentSearches: recent));
    } catch (_) {}
  }

  Future<void> loadTopics() async {
    try {
      final topics = await repository.getTopics();
      emit(state.copyWith(topics: topics));
    } catch (_) {}
  }

  Future<void> fetchWallpapers({
    bool isRefresh = false,
    bool randomize = false,
  }) async {
    if (!isRefresh && (state.status == WallpaperStatus.loading || state.hasReachedMax)) {
      return;
    }

    final isDailyPicks = (state.currentQuery == null || state.currentQuery!.isEmpty) &&
        (state.selectedCategory == null ||
            state.selectedCategory!.isEmpty ||
            state.selectedCategory == 'All');

    int targetPage = isRefresh ? 1 : state.page;
    if (randomize || (isRefresh && isDailyPicks)) {
      // Pick a random page offset for fresh variety
      targetPage = 1 + math.Random().nextInt(15);
    }

    if (isRefresh && isDailyPicks) {
      // Pick a distinct daily pick theme different from the previous one
      int themeIdx = math.Random().nextInt(_dailyPickThemes.length);
      if (_dailyPickThemes.length > 1 && themeIdx == _lastThemeIndex) {
        themeIdx = (themeIdx + 1) % _dailyPickThemes.length;
      }
      _lastThemeIndex = themeIdx;
      _currentDailyTheme = _dailyPickThemes[themeIdx];
    } else if (isRefresh && !isDailyPicks) {
      _currentDailyTheme = null;
    }

    final currentList = isRefresh ? <WallpaperEntity>[] : state.wallpapers;

    emit(state.copyWith(
      status: WallpaperStatus.loading,
      page: targetPage,
      wallpapers: currentList,
      hasReachedMax: isRefresh ? false : state.hasReachedMax,
      errorMessage: null,
    ));

    try {
      List<WallpaperEntity> newWallpapers = [];

      final query = state.currentQuery;
      final category = state.selectedCategory;
      final orientation = state.selectedOrientation ?? 'portrait';
      final color = state.selectedColor;
      final sortBy = state.selectedSort;
      final source = state.selectedSource;

      // Smart order variation when randomizing to prevent stale cached order
      final sortOptions = ['popular', 'latest', 'relevant'];
      final effectiveSortBy = (randomize && isDailyPicks)
          ? sortOptions[math.Random().nextInt(sortOptions.length)]
          : sortBy;

      if (query != null && query.isNotEmpty) {
        newWallpapers = await repository.searchWallpapers(
          query: query,
          page: targetPage,
          orderBy: sortBy,
          orientation: orientation,
          color: color,
          source: source,
        );
      } else if (category != null && category.isNotEmpty && category != 'All') {
        final categoryQuery = AppCategories.getSearchQueryForCategory(category);
        newWallpapers = await repository.searchWallpapers(
          query: categoryQuery,
          page: targetPage,
          orderBy: sortBy,
          orientation: orientation,
          color: color,
          source: source,
        );
      } else {
        // Daily Picks: Use rotated dynamic curated theme for rich diversity
        final activeDailyQuery = _currentDailyTheme ?? _dailyPickThemes[0];
        newWallpapers = await repository.searchWallpapers(
          query: activeDailyQuery,
          page: targetPage,
          orderBy: effectiveSortBy,
          orientation: orientation,
          color: color,
          source: source,
        );

        // Fallback: If empty, try curated editorial photos
        if (newWallpapers.isEmpty) {
          newWallpapers = await repository.getCuratedWallpapers(
            page: targetPage,
            orderBy: effectiveSortBy,
            source: source,
          );
        }
      }

      // Strict vertical mobile wallpaper filter: Discard non-portrait wallpapers
      newWallpapers = newWallpapers.where((w) {
        if (w.width != null && w.height != null && w.width! > 0 && w.height! > 0) {
          return w.height! > w.width!;
        }
        return true;
      }).toList();

      // Deduplicate within the fetched list itself
      final uniqueNew = <String, WallpaperEntity>{};
      for (final w in newWallpapers) {
        if (w.id.isNotEmpty && !uniqueNew.containsKey(w.id)) {
          uniqueNew[w.id] = w;
        }
      }
      List<WallpaperEntity> dedupedList = uniqueNew.values.toList();

      if (isRefresh) {
        // Anti-repetition: Prioritize wallpapers the user hasn't seen recently
        final unseenWallpapers = <WallpaperEntity>[];
        final previouslySeen = <WallpaperEntity>[];

        for (final item in dedupedList) {
          if (_seenWallpaperIds.contains(item.id)) {
            previouslySeen.add(item);
          } else {
            unseenWallpapers.add(item);
          }
        }

        // Shuffle unseen wallpapers for maximum visual variety on refresh
        unseenWallpapers.shuffle(math.Random());

        dedupedList = [...unseenWallpapers, ...previouslySeen];

        // Track in session history buffer
        for (final item in dedupedList) {
          _seenWallpaperIds.add(item.id);
        }
        while (_seenWallpaperIds.length > _maxSeenHistory) {
          _seenWallpaperIds.remove(_seenWallpaperIds.first);
        }
      } else {
        // Pagination: filter out any that already exist in currentList
        final existingIds = currentList.map((w) => w.id).toSet();
        dedupedList = dedupedList.where((w) => !existingIds.contains(w.id)).toList();
        for (final item in dedupedList) {
          _seenWallpaperIds.add(item.id);
        }
      }

      final updatedList = List<WallpaperEntity>.from(currentList)..addAll(dedupedList);

      emit(state.copyWith(
        status: WallpaperStatus.loaded,
        wallpapers: updatedList,
        page: targetPage + 1,
        hasReachedMax: dedupedList.isEmpty,
        errorMessage: null,
      ));
    } catch (e) {
      String msg = 'No Internet Connection. Please check your network and try again.';
      final str = e.toString().toLowerCase();
      if (str.contains('rate limit') || str.contains('403') || str.contains('429')) {
        msg = 'API rate limit reached. Retrying with backup source...';
      } else if (str.contains('timeout') || str.contains('timed out')) {
        msg = 'Connection timed out. Please check your network connection.';
      } else if (str.contains('socket') || str.contains('network') || str.contains('no internet') || str.contains('noactiveinternet')) {
        msg = 'No Internet Connection. Please check your Wi-Fi or mobile data.';
      } else if (str.contains('server') || str.contains('500') || str.contains('502') || str.contains('503')) {
        msg = 'Server temporarily unavailable. Please retry in a moment.';
      }

      emit(state.copyWith(
        status: WallpaperStatus.failure,
        errorMessage: msg,
      ));
    }
  }

  Future<void> searchWallpapers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(clearQuery: true));
    } else {
      await searchLocalDataSource.saveSearchQuery(trimmed);
      await loadRecentSearches();
      emit(state.copyWith(currentQuery: trimmed, clearCategory: true));
    }
    await fetchWallpapers(isRefresh: true);
  }

  Future<void> removeRecentSearch(String query) async {
    await searchLocalDataSource.removeSearchQuery(query);
    await loadRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    await searchLocalDataSource.clearRecentSearches();
    await loadRecentSearches();
  }

  Future<void> selectCategory(String? category) async {
    if (category == null || category == 'All') {
      emit(state.copyWith(clearCategory: true, clearQuery: true));
    } else if (state.selectedCategory == category) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category, clearQuery: true));
    }
    await fetchWallpapers(isRefresh: true, randomize: true);
  }

  Future<void> applyFilters({
    String? orientation,
    String? color,
    String? sortBy,
    String? source,
  }) async {
    emit(state.copyWith(
      selectedOrientation: orientation,
      clearOrientation: orientation == null,
      selectedColor: color,
      clearColor: color == null,
      selectedSort: sortBy ?? state.selectedSort,
      selectedSource: source ?? state.selectedSource,
    ));
    await fetchWallpapers(isRefresh: true, randomize: true);
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(
      clearOrientation: true,
      clearColor: true,
      selectedSort: 'popular',
      selectedSource: 'all',
    ));
    await fetchWallpapers(isRefresh: true, randomize: true);
  }

  Future<void> downloadWallpaper(WallpaperEntity wallpaper) async {
    final updatedDownloadingIds = Set<String>.from(state.downloadingIds)..add(wallpaper.id);
    emit(state.copyWith(
      downloadStatus: WallpaperDownloadStatus.downloading,
      downloadingIds: updatedDownloadingIds,
      clearLastDownloadedId: true,
      clearLastFailedId: true,
      errorMessage: null,
    ));

    try {
      final savedPath = await repository.downloadWallpaper(wallpaper);
      await loadDownloadedWallpapers();
      final finishedDownloadingIds = Set<String>.from(state.downloadingIds)..remove(wallpaper.id);
      emit(state.copyWith(
        downloadStatus: WallpaperDownloadStatus.downloaded,
        downloadingIds: finishedDownloadingIds,
        lastDownloadedId: wallpaper.id,
        downloadedFilePath: savedPath,
        errorMessage: null,
      ));
    } catch (e) {
      final finishedDownloadingIds = Set<String>.from(state.downloadingIds)..remove(wallpaper.id);
      String msg = 'Download failed. Please check your internet connection.';
      final str = e.toString().toLowerCase();
      if (str.contains('socket') || str.contains('network') || str.contains('no internet')) {
        msg = 'Download failed: No Internet Connection.';
      } else if (str.contains('permission') || str.contains('storage')) {
        msg = 'Download failed: Storage permission required.';
      }
      emit(state.copyWith(
        downloadStatus: WallpaperDownloadStatus.failure,
        downloadingIds: finishedDownloadingIds,
        lastFailedId: wallpaper.id,
        errorMessage: msg,
      ));
    }
  }

  Future<void> applyWallpaperToDevice({
    required String imagePathOrUrl,
    required WallpaperTarget target,
  }) async {
    emit(state.copyWith(
      applyStatus: WallpaperApplyStatus.applying,
      errorMessage: null,
    ));
    try {
      final success = await repository.applyWallpaper(
        imagePathOrUrl: imagePathOrUrl,
        target: target,
      );
      if (success) {
        emit(state.copyWith(
          applyStatus: WallpaperApplyStatus.success,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          applyStatus: WallpaperApplyStatus.failure,
          errorMessage: 'Could not set wallpaper on this device.',
        ));
      }
    } catch (e) {
      String msg = 'Could not set wallpaper on this device.';
      final str = e.toString().toLowerCase();
      if (str.contains('permission')) {
        msg = 'Permission required to change device wallpaper.';
      }
      emit(state.copyWith(
        applyStatus: WallpaperApplyStatus.failure,
        errorMessage: msg,
      ));
    }
  }

  Future<void> loadDownloadedWallpapers() async {
    try {
      final downloaded = await repository.getDownloadedWallpapers();
      emit(state.copyWith(downloadedWallpapers: downloaded));
    } catch (_) {}
  }

  Future<bool> checkIfDownloaded(String wallpaperId) async {
    return await repository.isWallpaperDownloaded(wallpaperId);
  }

  void resetDownloadAndApplyStatus() {
    emit(state.copyWith(
      downloadStatus: WallpaperDownloadStatus.initial,
      applyStatus: WallpaperApplyStatus.initial,
      clearLastDownloadedId: true,
      clearLastFailedId: true,
      downloadedFilePath: null,
      errorMessage: null,
    ));
  }
}
