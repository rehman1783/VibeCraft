import '../../domain/entities/chat_message_entity.dart';

class AiChatMessageModel extends ChatMessageEntity {
  const AiChatMessageModel({
    super.id,
    required super.text,
    required super.isUser,
    super.optimizedPrompt,
    super.timestamp,
    super.suggestedStyles,
  });

  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) {
    return AiChatMessageModel(
      id: json['id'] as String?,
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      optimizedPrompt: json['optimizedPrompt'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      suggestedStyles: (json['suggestedStyles'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'optimizedPrompt': optimizedPrompt,
      'timestamp': timestamp?.toIso8601String(),
      'suggestedStyles': suggestedStyles,
    };
  }

  factory AiChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return AiChatMessageModel(
      id: entity.id,
      text: entity.text,
      isUser: entity.isUser,
      optimizedPrompt: entity.optimizedPrompt,
      timestamp: entity.timestamp,
      suggestedStyles: entity.suggestedStyles,
    );
  }
}
