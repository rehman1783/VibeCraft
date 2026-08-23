import '../entities/chat_message_entity.dart';

abstract class AiRepository {
  /// Sends multi-turn chat messages to Gemini AI and returns conversational response
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> history,
    required String userMessage,
  });

  /// Optimizes and translates any user command (Urdu, Roman Urdu, English, shorthand) into a master 9:16 vertical prompt
  Future<String> optimizePrompt({
    required String prompt,
    String? style,
  });

  /// Generates high-fidelity vertical 9:16 customized wallpaper using Gemini / AI engine
  Future<String> generateWallpaper({
    required String prompt,
    String? style,
  });

  /// Synthesizes conversation history and style into an optimized master visual prompt
  String synthesizeMasterPrompt(List<ChatMessageEntity> history, {String? style});
}

