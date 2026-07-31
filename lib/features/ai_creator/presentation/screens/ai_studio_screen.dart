import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vibe_text_field.dart';
import '../cubit/ai_chat_cubit.dart';
import '../cubit/ai_chat_state.dart';
import '../widgets/interactive_chat_bubble.dart';

typedef AICreatorScreen = AiStudioScreen;

class AiStudioScreen extends StatefulWidget {
  const AiStudioScreen({super.key});

  @override
  State<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends State<AiStudioScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cubit = context.read<AiChatCubit>();

    final secondaryTextColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final footerBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final footerBorder = isDark ? null : Border(top: BorderSide(color: AppColors.lightBorder));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI CREATION STUDIO'),
      ),
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state.status == AiChatStatus.success && state.generatedImageUrl != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wallpaper Generated Successfully!')),
            );
            cubit.resetGeneration();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // 1. Dynamic Messaging Screen Body Window
              Expanded(
                child: state.status == AiChatStatus.generatingImage
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'AI is painting your customized wallpaper...',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.messages.length + (state.status == AiChatStatus.typing ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.messages.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Assistant is thinking...',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }
                          return InteractiveChatBubble(
                            message: state.messages[index],
                            onGenerateTap: (prompt) => cubit.generateWallpaper(prompt),
                          );
                        },
                      ),
              ),

              // 2. Reusable Footer Input Control Panel Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: () {
                            if (_promptController.text.trim().isNotEmpty) {
                              cubit.sendPrompt(_promptController.text);
                              _promptController.clear();
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