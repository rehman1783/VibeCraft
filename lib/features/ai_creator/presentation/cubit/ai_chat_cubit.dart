import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../wallpaper_explore/domain/entities/wallpaper_entity.dart';
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
                  "Hey! I am VibeCraft AI. Describe any wallpaper you want (in English or Urdu), and I will generate a breathtaking 9:16 vertical masterpiece for you!",
              isUser: false,
              suggestedStyles: [
                'Cyberpunk Neon',
                'Anime Studio',
                'Dark OLED Fantasy',
                'Minimalist 3D',
                'Neon Tokyo',
                'Synthwave Sunset',
                'Bioluminescent Nature',
                'Cosmic Nebula',
              ],
            ),
          ],
        ));

  /// Directly processes the user command, optimizes it, and generates the wallpaper
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
      status: AiChatStatus.generatingImage,
      messages: updatedMessages,
      lastPrompt: trimmedText,
      selectedStyle: currentStyle,
    ));

    // Immediately trigger master prompt synthesis and wallpaper generation
    await generateWallpaper(trimmedText, style: currentStyle);
  }

  void selectStyle(String style) {
    emit(state.copyWith(selectedStyle: style));
  }

  /// Generate high-resolution vertical customized wallpaper using Gemini / AI engine
  Future<void> generateWallpaper(String prompt, {String? style}) async {
    final activeStyle = style ?? state.selectedStyle;

    emit(state.copyWith(
      status: AiChatStatus.generatingImage,
      lastPrompt: prompt,
      selectedStyle: activeStyle,
    ));

    try {
      // 1. Optimize and translate the prompt with Gemini into a 9:16 masterwork specification
      final masterVisualPrompt = await _aiRepository.optimizePrompt(
        prompt: prompt,
        style: activeStyle,
      );

      // 2. Generate and locally cache the 8k high-fidelity image
      final generatedImagePathOrUrl = await _aiRepository.generateWallpaper(
        prompt: masterVisualPrompt,
        style: activeStyle,
      );

      final wallpaperEntity = WallpaperEntity(
        id: 'ai_gen_${DateTime.now().millisecondsSinceEpoch}',
        thumbnailUrl: generatedImagePathOrUrl,
        highResUrl: generatedImagePathOrUrl,
        rawUrl: generatedImagePathOrUrl,
        photographer: 'VibeCraft AI Studio',
        photographerUsername: 'vibecraft_ai',
        altDescription: prompt,
        source: 'VibeCraft AI',
        color: '#8B3CFF',
        likes: 1248,
        width: 1080,
        height: 1920,
      );

      final aiMessage = ChatMessageEntity(
        text: '✨ Generated wallpaper for: "$prompt"',
        isUser: false,
        optimizedPrompt: masterVisualPrompt,
        imagePathOrUrl: generatedImagePathOrUrl,
        wallpaper: wallpaperEntity,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        status: AiChatStatus.success,
        generatedImageUrl: generatedImagePathOrUrl,
        generatedWallpaper: wallpaperEntity,
        lastPrompt: prompt,
        messages: List<ChatMessageEntity>.from(state.messages)..add(aiMessage),
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
              "Hey! I am VibeCraft AI. Describe any wallpaper you want (in English or Urdu), and I will generate a breathtaking 9:16 vertical masterpiece for you!",
          isUser: false,
          suggestedStyles: [
            'Cyberpunk Neon',
            'Anime Studio',
            'Dark OLED Fantasy',
            'Minimalist 3D',
            'Neon Tokyo',
            'Synthwave Sunset',
            'Bioluminescent Nature',
            'Cosmic Nebula',
          ],
        ),
      ],
    ));
  }
}