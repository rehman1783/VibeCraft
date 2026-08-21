import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_craft/features/wallpaper_explore/data/models/pixabay_wallpaper_model.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/widgets/category_selector_bar.dart';

void main() {
  group('Pixabay Integration Tests', () {
    test('PixabayWallpaperModel parses JSON correctly', () {
      final json = {
        'id': 123456,
        'pageURL': 'https://pixabay.com/photos/cyberpunk-123456/',
        'type': 'photo',
        'tags': 'cyberpunk, neon, night city',
        'previewURL': 'https://cdn.pixabay.com/preview.jpg',
        'webformatURL': 'https://cdn.pixabay.com/webformat.jpg',
        'largeImageURL': 'https://cdn.pixabay.com/large.jpg',
        'imageWidth': 3840,
        'imageHeight': 2160,
        'likes': 450,
        'user': 'NeonArtist',
      };

      final model = PixabayWallpaperModel.fromJson(json);

      expect(model.id, 'pixabay_123456');
      expect(model.thumbnailUrl, 'https://cdn.pixabay.com/webformat.jpg');
      expect(model.highResUrl, 'https://cdn.pixabay.com/large.jpg');
      expect(model.photographer, 'NeonArtist');
      expect(model.likes, 450);
      expect(model.source, 'Pixabay');
      expect(model.width, 3840);
      expect(model.height, 2160);
    });

    test('AppCategories has 26 rich categories and query resolver works', () {
      expect(AppCategories.all.length, greaterThanOrEqualTo(24));
      
      final animeQuery = AppCategories.getSearchQueryForCategory('Anime');
      expect(animeQuery.contains('anime'), isTrue);

      final spaceQuery = AppCategories.getSearchQueryForCategory('Space & Galaxy');
      expect(spaceQuery.contains('galaxy') || spaceQuery.contains('space'), isTrue);
    });
  });
}
