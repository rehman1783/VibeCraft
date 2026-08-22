class ChatMessageEntity {
  final String? id;
  final String text;
  final bool isUser;
  final String? optimizedPrompt; // Holds the synthesized 9:16 master visual prompt
  final DateTime? timestamp;
  final List<String>? suggestedStyles;

  const ChatMessageEntity({
    this.id,
    required this.text,
    required this.isUser,
    this.optimizedPrompt,
    this.timestamp,
    this.suggestedStyles,
  });

  ChatMessageEntity copyWith({
    String? id,
    String? text,
    bool? isUser,
    String? optimizedPrompt,
    DateTime? timestamp,
    List<String>? suggestedStyles,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      optimizedPrompt: optimizedPrompt ?? this.optimizedPrompt,
      timestamp: timestamp ?? this.timestamp,
      suggestedStyles: suggestedStyles ?? this.suggestedStyles,
    );
  }
}