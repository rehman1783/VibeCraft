// lib/features/ai_creator/presentation/cubit/ai_chat_state.dart
import '../../domain/entities/chat_message_entity.dart';

enum AiChatStatus { initial, typing, responseReceived, generatingImage, success, failure }

class AiChatState {
  final AiChatStatus status;
  final List<ChatMessageEntity> messages;
  final String? generatedImageUrl;
  final String errorMessage;

  const AiChatState({
    this.status = AiChatStatus.initial,
    this.messages = const [],
    this.generatedImageUrl,
    this.errorMessage = '',
  });

  AiChatState copyWith({
    AiChatStatus? status,
    List<ChatMessageEntity>? messages,
    String? generatedImageUrl,
    String? errorMessage,
  }) {
    return AiChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}