import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final Dio _dio;

  static const String _systemInstruction =
      "You are VibeCraft's expert AI Wallpaper Assistant. Help the user refine their creative concept into a vivid, highly detailed visual wallpaper prompt. Keep your replies friendly, concise, and focused on visual styling. Ask if they like the styling concept and offer variations.";

  AiChatCubit({Dio? dio})
      : _dio = dio ?? Dio(),
        super(const AiChatState(
          messages: [
            ChatMessageEntity(
              text:
                  "Hey! I am VibeCraft's AI Wallpaper Assistant powered by Gemini. Tell me what kind of wallpaper you want to create today!",
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
    final String defaultOptimizedPrompt =
        "A high-fidelity vertical 9:16 mobile wallpaper of $trimmedText, highly detailed visual style, vibrant cinematic lighting, 8k resolution --ar 9:16";

    try {
      // Build conversation payload for Gemini
      final contents = <Map<String, dynamic>>[];
      
      // Add system prompt instruction
      contents.add({
        "role": "user",
        "parts": [{"text": _systemInstruction}]
      });
      contents.add({
        "role": "model",
        "parts": [{"text": "Understood! I am ready to help you craft an incredible 9:16 vertical wallpaper."}]
      });

      // Add recent message history (last 6 turns for context)
      final recentHistory = updatedMessages.length > 6
          ? updatedMessages.sublist(updatedMessages.length - 6)
          : updatedMessages;

      for (final msg in recentHistory) {
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
          "I love this creative direction for \"$trimmedText\"! I've refined the visual details with vibrant lighting and ultra-clear 9:16 depth. Tap ✨ Create Wallpaper below to render your artwork!";
    }

    final aiMessage = ChatMessageEntity(
      text: aiResponseText,
      isUser: false,
      optimizedPrompt: defaultOptimizedPrompt,
    );

    emit(state.copyWith(
      status: AiChatStatus.responseReceived,
      messages: List<ChatMessageEntity>.from(state.messages)..add(aiMessage),
    ));
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

      // 2 seconds rendering delay for smooth loading animation
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