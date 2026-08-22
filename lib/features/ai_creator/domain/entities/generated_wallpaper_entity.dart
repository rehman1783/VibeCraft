class GeneratedWallpaperEntity {
  final String id;
  final String prompt;
  final String imageUrl;
  final String? localFilePath;
  final String? style;
  final DateTime createdAt;
  final bool isBase64;

  const GeneratedWallpaperEntity({
    required this.id,
    required this.prompt,
    required this.imageUrl,
    this.localFilePath,
    this.style,
    required this.createdAt,
    this.isBase64 = false,
  });
}
