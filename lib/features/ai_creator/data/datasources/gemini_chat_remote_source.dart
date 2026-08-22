import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class GeminiChatRemoteDataSource {
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> history,
    required String userMessage,
  });
}

class GeminiChatRemoteDataSourceImpl implements GeminiChatRemoteDataSource {
  final Dio dio;

  static const String _systemInstruction =
      "You are VibeCraft AI, a creative, visionary, and intuitive AI Wallpaper Architect. "
      "Chat with the user naturally like an expert digital artist and wallpaper designer. "
      "Listen carefully to their ideas, recommend inspiring aesthetic directions (e.g. Cyberpunk Neon, "
      "AMOLED Dark Fantasy, Anime Studio, Minimalist 3D, Bioluminescent Nature, Retro Synthwave), "
      "discuss lighting, mood, color palettes, and composition. "
      "Maintain full context memory of all previous messages.";

  GeminiChatRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? Dio();

  @override
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> history,
    required String userMessage,
  }) async {
    final apiKey = AppConfig.geminiApiKey;
    final apiVersion = AppConfig.geminiApiVersion;
    final modelVersion = AppConfig.geminiModelVersion;
    final baseUrl = AppConfig.geminiBaseUrl;

    try {
      final contents = <Map<String, dynamic>>[];

      // Initial system persona priming
      contents.add({
        "role": "user",
        "parts": [
          {"text": _systemInstruction}
        ]
      });
      contents.add({
        "role": "model",
        "parts": [
          {
            "text":
                "Greetings! I am VibeCraft AI, your Wallpaper Architect. I am ready to collaborate with you on designing breathtaking vertical mobile wallpapers."
          }
        ]
      });

      // Append multi-turn history
      for (final msg in history) {
        contents.add({
          "role": msg.isUser ? "user" : "model",
          "parts": [
            {"text": msg.text}
          ]
        });
      }

      // Append latest user message
      contents.add({
        "role": "user",
        "parts": [
          {"text": userMessage}
        ]
      });

      final url =
          '$baseUrl/$apiVersion/models/$modelVersion:generateContent?key=$apiKey';

      final response = await dio.post(
        url,
        data: {"contents": contents},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['candidates'] != null &&
            (data['candidates'] as List).isNotEmpty) {
          final firstCandidate = data['candidates'][0];
          final parts = firstCandidate['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      }
    } catch (_) {
      // Fallback handled below
    }

    return "That's a fantastic idea! What color palette or lighting vibe do you envision for this wallpaper? (e.g. Neon Cyberpunk, Dark AMOLED Glow, or Soft Sunset Pastels)";
  }
}
