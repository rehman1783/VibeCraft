import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final AiRepository _aiRepository;

  AiChatCubit({required AiRepository aiRepository})
      : _aiRepository = aiRepository,
        super(const AiChatState(
          messages: [
            ChatMessageEntity(
              text:
                  "Hey! I am VibeCraft AI, your personal Wallpaper Architect. "
                  "Describe your dream wallpaper, choose a style, and let's craft an 8K mobile masterpiece together!",
              isUser: false,
              suggestedStyles: [
                'Cyberpunk Neon',
                'Anime Studio',
                'Dark OLED Fantasy',
                'Minimalist 3D',
                'Neon Tokyo',
                'Synthwave Sunset',
                'Bioluminescent Forest',
                'Cosmic Nebula',
              ],
            ),
          ],
        ));

  /// Send prompt to Gemini AI to refine wallpaper idea and conversation history
  Future<void> sendPrompt(String text, {String? styleOverride}) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final currentStyle = styleOverride ?? state.selectedStyle;

    final userMessage = ChatMessageEntity(
      text: trimmedText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessageEntity>.from(state.messages)
      ..add(userMessage);

    emit(state.copyWith(
      status: AiChatStatus.typing,
      messages: updatedMessages,
    ));

    String aiResponseText = '';

    try {
      aiResponseText = await _aiRepository.sendChatMessage(
        history: updatedMessages,
        userMessage: trimmedText,
      );
    } catch (_) {
      aiResponseText =
          "I love this vision! Let's shape it with breathtaking lighting and fine details.";
    }

    // Synthesize full conversation history into a Master Visual Prompt (9:16 vertical)
    final masterPrompt = _aiRepository.synthesizeMasterPrompt(
      updatedMessages,
      style: currentStyle,
    );

    final aiMessage = ChatMessageEntity(
      text: aiResponseText,
      isUser: false,
      optimizedPrompt: masterPrompt,
      timestamp: DateTime.now(),
      suggestedStyles: [
        'Cyberpunk Neon',
        'Anime Studio',
        'Dark OLED Fantasy',
        'Minimalist 3D',
        'Neon Tokyo',
        'Synthwave Sunset',
      ],
    );

    emit(state.copyWith(
      status: AiChatStatus.responseReceived,
      messages: List<ChatMessageEntity>.from(state.messages)..add(aiMessage),
    ));
  }

  void selectStyle(String style) {
    emit(state.copyWith(selectedStyle: style));
  }

  /// Generate high-resolution vertical customized wallpaper using Gemini / AI engine
  Future<void> generateWallpaper(String prompt, {String? style}) async {
    emit(state.copyWith(
      status: AiChatStatus.generatingImage,
      lastPrompt: prompt,
    ));

    try {
      final generatedImagePathOrUrl = await _aiRepository.generateWallpaper(
        prompt: prompt,
        style: style ?? state.selectedStyle,
      );

      emit(state.copyWith(
        status: AiChatStatus.success,
        generatedImageUrl: generatedImagePathOrUrl,
        lastPrompt: prompt,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AiChatStatus.failure,
        errorMessage: 'Failed to generate wallpaper. Please try again.',
      ));
    }
  }

  void resetGeneration() {
    emit(state.copyWith(
      status: AiChatStatus.responseReceived,
      clearGeneratedImageUrl: true,
    ));
  }

  void clearChat() {
    emit(const AiChatState(
      messages: [
        ChatMessageEntity(
          text:
              "Hey! I am VibeCraft AI, your personal Wallpaper Architect. "
              "Describe your dream wallpaper, choose a style, and let's craft an 8K mobile masterpiece together!",
          isUser: false,
          suggestedStyles: [
            'Cyberpunk Neon',
            'Anime Studio',
            'Dark OLED Fantasy',
            'Minimalist 3D',
            'Neon Tokyo',
            'Synthwave Sunset',
          ],
        ),
      ],
    ));
  }
}