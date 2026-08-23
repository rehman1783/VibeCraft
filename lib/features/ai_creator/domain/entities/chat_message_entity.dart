import '../../../wallpaper_explore/domain/entities/wallpaper_entity.dart';

class ChatMessageEntity {
  final String? id;
  final String text;
  final bool isUser;
  final String? optimizedPrompt; // Holds the synthesized 9:16 master visual prompt
  final String? imagePathOrUrl; // Holds local or remote image path for generated wallpaper
  final WallpaperEntity? wallpaper; // Holds full WallpaperEntity if available
  final DateTime? timestamp;
  final List<String>? suggestedStyles;

  const ChatMessageEntity({
    this.id,
    required this.text,
    required this.isUser,
    this.optimizedPrompt,
    this.imagePathOrUrl,
    this.wallpaper,
    this.timestamp,
    this.suggestedStyles,
  });

  ChatMessageEntity copyWith({
    String? id,
    String? text,
    bool? isUser,
    String? optimizedPrompt,
    String? imagePathOrUrl,
    WallpaperEntity? wallpaper,
    DateTime? timestamp,
    List<String>? suggestedStyles,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      optimizedPrompt: optimizedPrompt ?? this.optimizedPrompt,
      imagePathOrUrl: imagePathOrUrl ?? this.imagePathOrUrl,
      wallpaper: wallpaper ?? this.wallpaper,
      timestamp: timestamp ?? this.timestamp,
      suggestedStyles: suggestedStyles ?? this.suggestedStyles,
    );
  }
}