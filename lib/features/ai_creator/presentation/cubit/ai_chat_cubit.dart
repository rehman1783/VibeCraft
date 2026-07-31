// lib/features/ai_creator/presentation/cubit/ai_chat_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit() : super(const AiChatState(
    messages: [
      ChatMessageEntity(text: "Hey! I am your AI prompt assistant. Tell me what kind of wallpaper you want to create today!", isUser: false),
    ]
  ));

  Future<void> sendPrompt(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessageEntity(text: text, isUser: true);
    final updatedMessages = List<ChatMessageEntity>.from(state.messages)..add(userMessage);

    emit(state.copyWith(status: AiChatStatus.typing, messages: updatedMessages));
    
    // Simulate Gemini LLM brainstorming prompt generation delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final aiMessage = ChatMessageEntity(
      text: "That sounds sick! I have optimized your prompt. Ready to render the cyberpunk grid?",
      isUser: false,
      optimizedPrompt: "A high-fidelity vertical 9:16 mobile wallpaper of $text, neon cyberpunk style, absolute dark obsidian shadows, 8k resolution --ar 9:16",
    );

    emit(state.copyWith(
      status: AiChatStatus.responseReceived,
      messages: List<ChatMessageEntity>.from(state.messages)..add(aiMessage),
    ));
  }

  Future<void> generateWallpaper(String prompt) async {
    emit(state.copyWith(status: AiChatStatus.generatingImage));

    // Simulate multi-engine free serverless generation lag
    await Future.delayed(const Duration(seconds: 3));

    emit(state.copyWith(
      status: AiChatStatus.success,
      generatedImageUrl: 'https://images.pexels.com/photos/2832382/pexels-photo-2832382.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
    ));
  }

  void resetGeneration() {
    emit(state.copyWith(status: AiChatStatus.responseReceived, generatedImageUrl: null));
  }
}