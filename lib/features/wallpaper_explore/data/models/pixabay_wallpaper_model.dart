import '../../domain/entities/wallpaper_entity.dart';

class PixabayWallpaperModel extends WallpaperEntity {
  const PixabayWallpaperModel({
    required super.id,
    required super.thumbnailUrl,
    required super.highResUrl,
    super.rawUrl,
    required super.photographer,
    super.photographerUsername,
    required super.altDescription,
    super.downloadLocation,
    super.color,
    super.likes,
    super.width,
    super.height,
    super.source = 'Pixabay',
  });

  factory PixabayWallpaperModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId != null
        ? 'pixabay_$rawId'
        : 'pixabay_${DateTime.now().millisecondsSinceEpoch}';

    final previewUrl = json['previewURL'] as String? ?? '';
    final webformatUrl = json['webformatURL'] as String? ?? '';
    final largeImageUrl = json['largeImageURL'] as String? ?? '';
    final fullHdUrl = json['fullHDURL'] as String? ?? '';
    final imageHdUrl = json['imageURL'] as String? ?? '';

    // Choose best quality image URLs
    final thumbUrl = webformatUrl.isNotEmpty ? webformatUrl : previewUrl;
    final highRes = largeImageUrl.isNotEmpty
        ? largeImageUrl
        : (fullHdUrl.isNotEmpty
            ? fullHdUrl
            : (webformatUrl.isNotEmpty ? webformatUrl : thumbUrl));
    final rawUrl = imageHdUrl.isNotEmpty ? imageHdUrl : highRes;

    final user = json['user'] as String? ?? 'Pixabay Artist';
    final tags = json['tags'] as String? ?? 'Pixabay Wallpaper';

    // Capitalize first letter of tags for a clean title
    final cleanDescription = tags.isNotEmpty
        ? tags
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(3)
            .join(' • ')
        : 'Pixabay Wallpaper';

    final likes = (json['likes'] as num?)?.toInt() ?? 0;
    final width = (json['imageWidth'] as num?)?.toInt() ??
        (json['webformatWidth'] as num?)?.toInt();
    final height = (json['imageHeight'] as num?)?.toInt() ??
        (json['webformatHeight'] as num?)?.toInt();

    return PixabayWallpaperModel(
      id: idStr,
      thumbnailUrl: thumbUrl,
      highResUrl: highRes,
      rawUrl: rawUrl,
      photographer: user.trim().isNotEmpty ? user.trim() : 'Pixabay Artist',
      photographerUsername: user.trim(),
      altDescription: cleanDescription,
      downloadLocation: '',
      color: null,
      likes: likes,
      width: width,
      height: height,
      source: 'Pixabay',
    );
  }

  WallpaperEntity toEntity() {
    return WallpaperEntity(
      id: id,
      thumbnailUrl: thumbnailUrl,
      highResUrl: highResUrl,
      rawUrl: rawUrl,
      photographer: photographer,
      photographerUsername: photographerUsername,
      altDescription: altDescription,
      downloadLocation: downloadLocation,
      color: color,
      likes: likes,
      width: width,
      height: height,
      source: 'Pixabay',
    );
  }
}
