import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/gemini_chat_remote_source.dart';
import '../datasources/gemini_image_remote_source.dart';

class AiRepositoryImpl implements AiRepository {
  final GeminiChatRemoteDataSource chatRemoteDataSource;
  final GeminiImageRemoteDataSource imageRemoteDataSource;

  AiRepositoryImpl({
    required this.chatRemoteDataSource,
    required this.imageRemoteDataSource,
  });

  @override
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> history,
    required String userMessage,
  }) async {
    return await chatRemoteDataSource.sendChatMessage(
      history: history,
      userMessage: userMessage,
    );
  }

  @override
  Future<String> optimizePrompt({
    required String prompt,
    String? style,
  }) async {
    return await chatRemoteDataSource.optimizePrompt(
      prompt: prompt,
      style: style,
    );
  }

  @override
  Future<String> generateWallpaper({
    required String prompt,
    String? style,
  }) async {
    return await imageRemoteDataSource.generateWallpaperImage(
      prompt: prompt,
      style: style,
    );
  }

  @override
  String synthesizeMasterPrompt(List<ChatMessageEntity> history, {String? style}) {
    final userConcepts = history
        .where((m) => m.isUser)
        .map((m) => m.text.trim())
        .where((text) => text.isNotEmpty)
        .join(', ');

    final styleModifier = (style != null && style.isNotEmpty) ? '$style style, ' : '';

    return "A high-fidelity 9:16 vertical mobile wallpaper of $userConcepts, ${styleModifier}highly detailed, 8k resolution, cinematic volumetric lighting, photorealistic stylized composition --ar 9:16";
  }
}
