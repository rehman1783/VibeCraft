import '../../domain/entities/generated_wallpaper_entity.dart';

class GeneratedImageModel extends GeneratedWallpaperEntity {
  const GeneratedImageModel({
    required super.id,
    required super.prompt,
    required super.imageUrl,
    super.localFilePath,
    super.style,
    required super.createdAt,
    super.isBase64,
  });

  factory GeneratedImageModel.fromJson(Map<String, dynamic> json) {
    return GeneratedImageModel(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      localFilePath: json['localFilePath'] as String?,
      style: json['style'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isBase64: json['isBase64'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'imageUrl': imageUrl,
      'localFilePath': localFilePath,
      'style': style,
      'createdAt': createdAt.toIso8601String(),
      'isBase64': isBase64,
    };
  }
}
