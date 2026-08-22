import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_craft/features/search/data/datasources/search_local_data_source.dart';
import 'package:vibe_craft/features/wallpaper_explore/data/models/unsplash_topic_model.dart';
import 'package:vibe_craft/features/wallpaper_explore/domain/entities/wallpaper_entity.dart';
import 'package:vibe_craft/features/wallpaper_explore/domain/repositories/wallpaper_repository.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_state.dart';

class MockSearchLocalDataSource implements SearchLocalDataSource {
  @override
  Future<List<String>> getRecentSearches() async => [];
  @override
  Future<void> saveSearchQuery(String query) async {}
  @override
  Future<void> removeSearchQuery(String query) async {}
  @override
  Future<void> clearRecentSearches() async {}
}

class TrackingWallpaperRepository implements WallpaperRepository {
  final List<String> queriedTerms = [];
  final List<int> queriedPages = [];
  final List<String?> queriedSorts = [];

  List<WallpaperEntity> customResults = [];

  @override
  Future<List<WallpaperEntity>> searchWallpapers({
    required String query,
    required int page,
    String? orderBy,
    String? orientation,
    String? color,
    String? source,
  }) async {
    queriedTerms.add(query);
    queriedPages.add(page);
    queriedSorts.add(orderBy);

    if (customResults.isNotEmpty) {
      return List<WallpaperEntity>.from(customResults);
    }

    return [
      WallpaperEntity(
        id: 'wall_${query}_${page}_1',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        highResUrl: 'https://example.com/full1.jpg',
        photographer: 'Artist 1',
        altDescription: '$query wallpaper',
        width: 1080,
        height: 1920,
      ),
      WallpaperEntity(
        id: 'wall_${query}_${page}_2',
        thumbnailUrl: 'https://example.com/thumb2.jpg',
        highResUrl: 'https://example.com/full2.jpg',
        photographer: 'Artist 2',
        altDescription: '$query wallpaper',
        width: 1080,
        height: 1920,
      ),
    ];
  }

  @override
  Future<List<WallpaperEntity>> getCuratedWallpapers({
    required int page,
    String? orderBy,
    String? source,
  }) async => [];

  @override
  Future<List<UnsplashTopicModel>> getTopics() async => [];

  @override
  Future<List<WallpaperEntity>> getTopicWallpapers({
    required String topicSlug,
    required int page,
    String? orientation,
  }) async => [];

  @override
  Future<String> downloadWallpaper(WallpaperEntity wallpaper) async => '';

  @override
  Future<List<WallpaperEntity>> getDownloadedWallpapers() async => [];

  @override
  Future<bool> isWallpaperDownloaded(String wallpaperId) async => false;

  @override
  Future<bool> applyWallpaper({
    required String imagePathOrUrl,
    required WallpaperTarget target,
  }) async => true;

  @override
  Future<void> clearAllDownloadedWallpapers() async {}
}

void main() {
  group('Daily Picks Dynamic Refresh Tests', () {
    late TrackingWallpaperRepository repository;
    late MockSearchLocalDataSource searchSource;
    late WallpaperCubit cubit;

    setUp(() {
      repository = TrackingWallpaperRepository();
      searchSource = MockSearchLocalDataSource();
      cubit = WallpaperCubit(
        repository: repository,
        searchLocalDataSource: searchSource,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('Refreshing Daily Picks rotates theme query on consecutive refreshes', () async {
      // First refresh (Daily picks)
      await cubit.fetchWallpapers(isRefresh: true, randomize: true);
      expect(cubit.state.status, equals(WallpaperStatus.loaded));
      expect(cubit.state.wallpapers.isNotEmpty, isTrue);
      expect(repository.queriedTerms.length, equals(1));
      final firstQuery = repository.queriedTerms.first;

      // Second refresh (Daily picks)
      await cubit.fetchWallpapers(isRefresh: true, randomize: true);
      expect(repository.queriedTerms.length, equals(2));
      final secondQuery = repository.queriedTerms[1];

      // Verify that query changed / rotated
      expect(firstQuery, isNot(equals(secondQuery)));
    });

    test('Anti-repetition prioritizes unseen wallpapers over seen ones on refresh', () async {
      // 1. First fetch with a set of wallpapers
      repository.customResults = [
        const WallpaperEntity(
          id: 'item_A',
          thumbnailUrl: 'thumbA',
          highResUrl: 'fullA',
          photographer: 'Photographer A',
          altDescription: 'A',
          width: 1080,
          height: 1920,
        ),
        const WallpaperEntity(
          id: 'item_B',
          thumbnailUrl: 'thumbB',
          highResUrl: 'fullB',
          photographer: 'Photographer B',
          altDescription: 'B',
          width: 1080,
          height: 1920,
        ),
      ];

      await cubit.fetchWallpapers(isRefresh: true, randomize: false);
      expect(cubit.state.wallpapers.map((w) => w.id).toSet(), equals({'item_A', 'item_B'}));

      // 2. Next refresh returns item_B (seen) and item_C (new unseen)
      repository.customResults = [
        const WallpaperEntity(
          id: 'item_B',
          thumbnailUrl: 'thumbB',
          highResUrl: 'fullB',
          photographer: 'Photographer B',
          altDescription: 'B',
          width: 1080,
          height: 1920,
        ),
        const WallpaperEntity(
          id: 'item_C',
          thumbnailUrl: 'thumbC',
          highResUrl: 'fullC',
          photographer: 'Photographer C',
          altDescription: 'C',
          width: 1080,
          height: 1920,
        ),
      ];

      await cubit.fetchWallpapers(isRefresh: true, randomize: false);
      final currentIds = cubit.state.wallpapers.map((w) => w.id).toList();

      // item_C (unseen) MUST be placed before item_B (seen)
      expect(currentIds.first, equals('item_C'));
      expect(currentIds.contains('item_B'), isTrue);
    });

    test('Duplicate wallpaper IDs in same batch are filtered out', () async {
      repository.customResults = [
        const WallpaperEntity(
          id: 'dup_1',
          thumbnailUrl: 'thumb1',
          highResUrl: 'full1',
          photographer: 'Photographer 1',
          altDescription: '1',
          width: 1080,
          height: 1920,
        ),
        const WallpaperEntity(
          id: 'dup_1', // Duplicate ID
          thumbnailUrl: 'thumb1_alt',
          highResUrl: 'full1_alt',
          photographer: 'Photographer 1 Alt',
          altDescription: '1 Alt',
          width: 1080,
          height: 1920,
        ),
        const WallpaperEntity(
          id: 'dup_2',
          thumbnailUrl: 'thumb2',
          highResUrl: 'full2',
          photographer: 'Photographer 2',
          altDescription: '2',
          width: 1080,
          height: 1920,
        ),
      ];

      await cubit.fetchWallpapers(isRefresh: true);
      expect(cubit.state.wallpapers.length, equals(2));
      expect(cubit.state.wallpapers.map((w) => w.id).toSet(), equals({'dup_1', 'dup_2'}));
    });
  });
}
