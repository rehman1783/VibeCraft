import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/report_content_bottom_sheet.dart';
import '../../../../core/widgets/vibe_text_field.dart';
import '../../../wallpaper_explore/presentation/screens/wallpaper_detail_screen.dart';
import '../cubit/ai_chat_cubit.dart';
import '../cubit/ai_chat_state.dart';
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

  void _showAiSafetyDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161826) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'AI Safety & Guidelines',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VibeCraft strictly complies with Google Play AI-Generated Content policies:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            _buildSafetyItem(
              Icons.check_circle_outline_rounded,
              'Zero Tolerance for Hate & NSFW',
              'Harassment, explicit sexual content, violence, and dangerous activities are prohibited.',
              isDark,
            ),
            const SizedBox(height: 8),
            _buildSafetyItem(
              Icons.flag_outlined,
              'In-App Flagging & Reporting',
              'Tap the Flag/Report button on any AI message or image to report offensive generations immediately.',
              isDark,
            ),
            const SizedBox(height: 8),
            _buildSafetyItem(
              Icons.timelapse_rounded,
              '24-Hour Review & Filtering',
              'Reports are human-reviewed to update safety filters and ban non-compliant content.',
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ReportContentBottomSheet.show(
                context: context,
                contentId:
                    'ai_studio_general_${DateTime.now().millisecondsSinceEpoch}',
                contentType: 'ai_chat_response',
                contentUrlOrText: 'General AI Studio Report',
              );
            },
            child: const Text(
              'Report an Issue',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyItem(
      IconData icon, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.3,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cubit = context.read<AiChatCubit>();

    final footerBg = isDark ? const Color(0xFF141520) : AppColors.lightSurface;
    final footerBorder = isDark
        ? Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))
        : Border(top: BorderSide(color: AppColors.lightBorder));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'AI CREATION STUDIO',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'AI Safety & Guidelines',
            icon: const Icon(Icons.shield_outlined, size: 22),
            onPressed: () => _showAiSafetyDialog(context),
          ),
          IconButton(
            tooltip: 'Clear History',
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () => cubit.clearChat(),
          ),
        ],
      ),
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state.status == AiChatStatus.success &&
              state.generatedWallpaper != null) {
            final wallpaper = state.generatedWallpaper!;
            cubit.resetGeneration();

            // Directly navigate to full Wallpaper Detail screen with all actions (Set, Save, Preview, Favorite)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WallpaperDetailScreen(wallpaper: wallpaper),
              ),
            );
          } else if (state.status == AiChatStatus.generatingImage ||
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
                              'A breathtaking $style vertical wallpaper with vibrant cinematic colors and 8k detail',
                              styleOverride: style,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              // Dynamic Screen Body: Live Generator or Chat History
              Expanded(
                child: isGenerating
                    ? GenerationShimmerCard(prompt: state.lastPrompt)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          return InteractiveChatBubble(
                            message: state.messages[index],
                            onGenerateTap: (prompt) =>
                                cubit.generateWallpaper(prompt),
                            onStyleTap: (style) {
                              cubit.selectStyle(style);
                              cubit.sendPrompt(
                                'A stunning $style vertical mobile wallpaper with high-end detail',
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
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
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
                          hintText: 'Describe any wallpaper to create...',
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 26,
                        child: IconButton(
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
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