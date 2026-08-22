import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vibe_text_field.dart';
import '../cubit/ai_chat_cubit.dart';
import '../cubit/ai_chat_state.dart';
import '../widgets/ai_generated_wallpaper_preview_dialog.dart';
import '../widgets/generation_shimmer_card.dart';
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

  static const List<String> _quickStyles = [
    'Cyberpunk Neon',
    'Anime Studio',
    'Dark OLED Fantasy',
    'Minimalist 3D',
    'Neon Tokyo',
    'Synthwave Sunset',
    'Bioluminescent Nature',
    'Cosmic Nebula',
  ];

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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'AI CREATION STUDIO',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear Chat',
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () => cubit.clearChat(),
          ),
        ],
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
              // Top Quick Style Exploration Bar
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F101A) : Colors.grey.shade100,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _quickStyles.length,
                  itemBuilder: (context, index) {
                    final style = _quickStyles[index];
                    final isSelected = state.selectedStyle == style;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          style,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF191B28)
                            : Colors.white,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.shade300),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (selected) {
                          cubit.selectStyle(selected ? style : '');
                          if (selected) {
                            cubit.sendPrompt(
                              'Suggest a stunning $style wallpaper concept with dramatic lighting and color palette.',
                              styleOverride: style,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              // Dynamic Messaging Screen Body Window / Loading State
              Expanded(
                child: isGenerating
                    ? GenerationShimmerCard(prompt: state.lastPrompt)
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
                                      'VibeCraft AI is refining with Gemini...',
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
                            onStyleTap: (style) {
                              cubit.selectStyle(style);
                              cubit.sendPrompt(
                                'Let’s make this in $style style with vivid details.',
                                styleOverride: style,
                              );
                            },
                          );
                        },
                      ),
              ),

              // Footer Input Control Panel Bar
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