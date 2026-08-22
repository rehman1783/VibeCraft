import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message_entity.dart';

class InteractiveChatBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final Function(String) onGenerateTap;
  final Function(String)? onStyleTap;

  const InteractiveChatBubble({
    super.key,
    required this.message,
    required this.onGenerateTap,
    this.onStyleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isUser = message.isUser;

    final assistantBubbleBg =
        isDark ? const Color(0xFF161824) : AppColors.lightSurface;
    final assistantBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.08))
        : Border.all(color: AppColors.lightBorder);
    final textColor = isUser
        ? Colors.white
        : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 6,
              bottom: 6,
              left: isUser ? 54 : 0,
              right: isUser ? 0 : 54,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : assistantBubbleBg,
              border: isUser ? null : assistantBorder,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: isUser
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'VibeCraft AI',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          // Suggested Styles Quick Selection Chips
          if (!isUser &&
              message.suggestedStyles != null &&
              message.suggestedStyles!.isNotEmpty &&
              onStyleTap != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 6.0, left: 4.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: message.suggestedStyles!.map((style) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          style,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF1E2030)
                            : Colors.grey.shade200,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onPressed: () => onStyleTap!(style),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Prominent "✨ Create Wallpaper" Action Button for AI Messages
          if (!isUser && message.optimizedPrompt != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0, top: 4.0, left: 4.0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B3CFF), Color(0xFF651FFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B3CFF).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => onGenerateTap(message.optimizedPrompt!),
                  icon: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    '✨ Create Wallpaper',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
