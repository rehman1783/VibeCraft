class WallpaperEntity {
  final String id;
  final String thumbnailUrl; // Used for fast-loading in the main grid
  final String highResUrl; // Full resolution photo
  final String rawUrl; // Raw resolution photo
  final String photographer;
  final String photographerUsername;
  final String altDescription;
  final String downloadLocation; // Unsplash tracking endpoint
  final String? color; // Dominant hex color code
  final int likes;
  final int? width;
  final int? height;

  const WallpaperEntity({
    required this.id,
    required this.thumbnailUrl,
    required this.highResUrl,
    this.rawUrl = '',
    required this.photographer,
    this.photographerUsername = '',
    required this.altDescription,
    this.downloadLocation = '',
    this.color,
    this.likes = 0,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thumbnailUrl': thumbnailUrl,
      'highResUrl': highResUrl,
      'rawUrl': rawUrl,
      'photographer': photographer,
      'photographerUsername': photographerUsername,
      'altDescription': altDescription,
      'downloadLocation': downloadLocation,
      'color': color,
      'likes': likes,
      'width': width,
      'height': height,
    };
  }

  factory WallpaperEntity.fromJson(Map<String, dynamic> json) {
    return WallpaperEntity(
      id: json['id'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      highResUrl: json['highResUrl'] as String? ?? '',
      rawUrl: json['rawUrl'] as String? ?? '',
      photographer: json['photographer'] as String? ?? 'Unsplash Artist',
      photographerUsername: json['photographerUsername'] as String? ?? '',
      altDescription:
          json['altDescription'] as String? ?? 'VibeCraft Wallpaper',
      downloadLocation: json['downloadLocation'] as String? ?? '',
      color: json['color'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );
  }
}
