import '../entities/chat_message_entity.dart';
import '../repositories/ai_repository.dart';

class SendChatPromptUseCase {
  final AiRepository repository;

  const SendChatPromptUseCase(this.repository);

  Future<String> call({
    required List<ChatMessageEntity> history,
    required String userMessage,
  }) async {
    return await repository.sendChatMessage(
      history: history,
      userMessage: userMessage,
    );
  }
}
