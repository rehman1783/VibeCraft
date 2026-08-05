import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vibe_text_field.dart';
import '../cubit/ai_chat_cubit.dart';
import '../cubit/ai_chat_state.dart';
import '../widgets/ai_generated_wallpaper_preview_dialog.dart';
import '../widgets/interactive_chat_bubble.dart';

typedef AICreatorScreen = AiStudioScreen;

class AiStudioScreen extends StatefulWidget {
  const AiStudioScreen({super.key});

  @override
  State<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends State<AiStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cubit = context.read<AiChatCubit>();

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final footerBg = isDark ? const Color(0xFF141520) : AppColors.lightSurface;
    final footerBorder = isDark
        ? Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))
        : Border(top: BorderSide(color: AppColors.lightBorder));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI CREATION STUDIO',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state.status == AiChatStatus.success &&
              state.generatedImageUrl != null) {
            final prompt = state.lastPrompt ?? 'AI Vertical Wallpaper';
            final imageUrl = state.generatedImageUrl!;

            cubit.resetGeneration();

            AiGeneratedWallpaperPreviewDialog.show(
              context: context,
              imageUrl: imageUrl,
              prompt: prompt,
              onRegenerate: () => cubit.generateWallpaper(prompt),
            );
          } else if (state.status == AiChatStatus.typing ||
              state.status == AiChatStatus.responseReceived) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final isGenerating = state.status == AiChatStatus.generatingImage;

          return Column(
            children: [
              // 1. Dynamic Messaging Screen Body Window / Loading State
              Expanded(
                child: isGenerating
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF141520)
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Translating your thoughts into an 8K wallpaper...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rendering high-resolution 9:16 portrait artwork with Gemini AI...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.messages.length +
                            (state.status == AiChatStatus.typing ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.messages.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'VibeCraft AI is refining your prompt...',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return InteractiveChatBubble(
                            message: state.messages[index],
                            onGenerateTap: (prompt) =>
                                cubit.generateWallpaper(prompt),
                          );
                        },
                      ),
              ),

              // 2. Footer Input Control Panel Bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: footerBg,
                  border: footerBorder,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: VibeTextField(
                          controller: _promptController,
                          hintText: 'Describe your dream wallpaper...',
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 26,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final prompt = _promptController.text.trim();
                            if (prompt.isNotEmpty) {
                              cubit.sendPrompt(prompt);
                              _promptController.clear();
                              _scrollToBottom();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}