import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final Dio _dio;

  static const String _systemInstruction =
      "You are VibeCraft AI, a creative, friendly, and intuitive AI Wallpaper Architect. "
      "Chat with the user naturally—just like standard ChatGPT or Gemini. Listen carefully to their ideas, "
      "ask refining questions about style, lighting, colors, and mood, and maintain full conversation memory. "
      "Do not rush to generate images immediately unless the user's idea is complete. "
      "Once the user confirms they like the concept, synthesize the entire conversation into an extremely detailed visual art prompt.";

  AiChatCubit({Dio? dio})
      : _dio = dio ?? Dio(),
        super(const AiChatState(
          messages: [
            ChatMessageEntity(
              text:
                  "Hey! I am VibeCraft AI, your AI Wallpaper Architect. Tell me your wallpaper idea, and we'll refine the style, lighting, and mood together!",
              isUser: false,
            ),
          ],
        ));

  Future<void> sendPrompt(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final userMessage = ChatMessageEntity(text: trimmedText, isUser: true);
    final updatedMessages = List<ChatMessageEntity>.from(state.messages)
      ..add(userMessage);

    emit(state.copyWith(
      status: AiChatStatus.typing,
      messages: updatedMessages,
    ));

    final apiKey = dotenv.env['GEMINI_API_KEY'] ??
        'AQ.Ab8RN6InhZzuo4z4WQ9sjHrzMaHCcd99eiMhOpjWUPrxU76DyQ';

    String aiResponseText = '';

    try {
      // Build full multi-turn conversation payload for Gemini
      final contents = <Map<String, dynamic>>[];

      // System persona instruction as initial context
      contents.add({
        "role": "user",
        "parts": [{"text": _systemInstruction}]
      });
      contents.add({
        "role": "model",
        "parts": [
          {
            "text":
                "Understood! I am VibeCraft AI. I will maintain full context memory, chat naturally, and help refine wallpaper ideas."
          }
        ]
      });

      // Pass ALL conversation messages in chronological order for full memory
      for (final msg in updatedMessages) {
        contents.add({
          "role": msg.isUser ? "user" : "model",
          "parts": [{"text": msg.text}]
        });
      }

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
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
            aiResponseText = parts[0]['text'] ?? '';
          }
        }
      }
    } catch (_) {}

    if (aiResponseText.trim().isEmpty) {
      aiResponseText =
          "That's a great concept! What style or mood would you prefer for this wallpaper? (e.g. Cyberpunk, Minimalist 3D, Vibrant Anime, or Photorealistic)";
    }

    // Synthesize Master Visual Prompt combining entire conversation history
    final masterPrompt = _synthesizeMasterPrompt(updatedMessages);

    final aiMessage = ChatMessageEntity(
      text: aiResponseText,
      isUser: false,
      optimizedPrompt: masterPrompt,
    );

    emit(state.copyWith(
      status: AiChatStatus.responseReceived,
      messages: List<ChatMessageEntity>.from(state.messages)..add(aiMessage),
    ));
  }

  /// Synthesizes full conversation history into a Master Visual Art Prompt (9:16 vertical)
  String _synthesizeMasterPrompt(List<ChatMessageEntity> history) {
    final userPreferences = history
        .where((m) => m.isUser)
        .map((m) => m.text)
        .join(', ');

    return "A high-fidelity 9:16 vertical mobile wallpaper of $userPreferences, highly detailed, 8k resolution, cinematic lighting, photorealistic, stylized composition --ar 9:16";
  }

  Future<void> generateWallpaper(String prompt) async {
    emit(state.copyWith(
      status: AiChatStatus.generatingImage,
      lastPrompt: prompt,
    ));

    try {
      final encodedPrompt = Uri.encodeComponent(prompt);
      final seed = DateTime.now().millisecondsSinceEpoch % 100000;
      final generatedImageUrl =
          'https://image.pollinations.ai/prompt/$encodedPrompt?width=720&height=1280&nologo=true&seed=$seed';

      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(
        status: AiChatStatus.success,
        generatedImageUrl: generatedImageUrl,
        lastPrompt: prompt,
      ));
    } catch (e) {
      emit(state.copyWith(status: AiChatStatus.failure));
    }
  }

  void resetGeneration() {
    emit(state.copyWith(
      status: AiChatStatus.responseReceived,
      generatedImageUrl: null,
    ));
  }
}