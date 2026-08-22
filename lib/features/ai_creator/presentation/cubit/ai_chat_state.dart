import '../../domain/entities/chat_message_entity.dart';

enum AiChatStatus {
  initial,
  typing,
  responseReceived,
  generatingImage,
  success,
  failure,
}

class AiChatState {
  final AiChatStatus status;
  final List<ChatMessageEntity> messages;
  final String? generatedImageUrl;
  final String? lastPrompt;
  final String? selectedStyle;
  final String errorMessage;

  const AiChatState({
    this.status = AiChatStatus.initial,
    this.messages = const [],
    this.generatedImageUrl,
    this.lastPrompt,
    this.selectedStyle,
    this.errorMessage = '',
  });

  AiChatState copyWith({
    AiChatStatus? status,
    List<ChatMessageEntity>? messages,
    String? generatedImageUrl,
    bool clearGeneratedImageUrl = false,
    String? lastPrompt,
    String? selectedStyle,
    String? errorMessage,
  }) {
    return AiChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      generatedImageUrl: clearGeneratedImageUrl
          ? null
          : (generatedImageUrl ?? this.generatedImageUrl),
      lastPrompt: lastPrompt ?? this.lastPrompt,
      selectedStyle: selectedStyle ?? this.selectedStyle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}