import '../../domain/entities/wallpaper_entity.dart';

class UnsplashWallpaperModel extends WallpaperEntity {
  const UnsplashWallpaperModel({
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
    super.source = 'Unsplash',
  });

  factory UnsplashWallpaperModel.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>? ?? {};
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final links = json['links'] as Map<String, dynamic>? ?? {};

    final thumbUrl =
        urls['small'] as String? ??
        urls['thumb'] as String? ??
        urls['regular'] as String? ??
        '';

    final regularUrl =
        urls['regular'] as String? ??
        urls['full'] as String? ??
        urls['small'] as String? ??
        '';

    final rawUrl = urls['raw'] as String? ?? regularUrl;

    final photographer =
        user['name'] as String? ??
        user['username'] as String? ??
        'Unsplash Artist';
    final photographerUsername = user['username'] as String? ?? '';

    final description =
        json['description'] as String? ??
        json['alt_description'] as String? ??
        'VibeCraft Wallpaper';

    final downloadLoc = links['download_location'] as String? ?? '';

    return UnsplashWallpaperModel(
      id: json['id'] as String? ?? '',
      thumbnailUrl: thumbUrl,
      highResUrl: regularUrl,
      rawUrl: rawUrl,
      photographer: photographer,
      photographerUsername: photographerUsername,
      altDescription: description,
      downloadLocation: downloadLoc,
      color: json['color'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      source: 'Unsplash',
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
      source: 'Unsplash',
    );
  }
}
