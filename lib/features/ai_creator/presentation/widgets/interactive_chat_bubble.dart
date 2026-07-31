import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vibe_button.dart';
import '../../domain/entities/chat_message_entity.dart';

class InteractiveChatBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final Function(String) onGenerateTap;

  const InteractiveChatBubble({
    super.key,
    required this.message,
    required this.onGenerateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isUser = message.isUser;

    final assistantBubbleBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final assistantBorder = isDark ? null : Border.all(color: AppColors.lightBorder);
    final textColor = isUser
        ? Colors.white
        : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: isUser ? 48 : 0,
              right: isUser ? 0 : 48,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : assistantBubbleBg,
              border: isUser ? null : assistantBorder,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 16),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
              ),
            ),
          ),
          if (!isUser && message.optimizedPrompt != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
              child: SizedBox(
                width: 225,
                child: VibeButton(
                  label: "✨ Create Wallpaper",
                  icon: Icons.auto_awesome_rounded,
                  onPressed: () => onGenerateTap(message.optimizedPrompt!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
