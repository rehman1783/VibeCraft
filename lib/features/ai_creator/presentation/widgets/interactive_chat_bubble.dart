import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/content_report_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/report_content_bottom_sheet.dart';
import '../../../../injection_container.dart';
import '../../../wallpaper_explore/presentation/screens/wallpaper_detail_screen.dart';
import '../../domain/entities/chat_message_entity.dart';

class InteractiveChatBubble extends StatefulWidget {
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
  State<InteractiveChatBubble> createState() => _InteractiveChatBubbleState();
}

class _InteractiveChatBubbleState extends State<InteractiveChatBubble> {
  bool _isReported = false;

  @override
  void initState() {
    super.initState();
    _checkReportedStatus();
  }

  void _checkReportedStatus() {
    final msg = widget.message;
    final contentId = msg.id ??
        'msg_${msg.timestamp?.millisecondsSinceEpoch ?? msg.text.hashCode}';
    final service = sl<ContentReportService>();
    if (service.isContentReported(contentId)) {
      _isReported = true;
    }
  }

  void _onReportMessage(BuildContext context) {
    final msg = widget.message;
    final contentId = msg.id ??
        'msg_${msg.timestamp?.millisecondsSinceEpoch ?? msg.text.hashCode}';

    ReportContentBottomSheet.show(
      context: context,
      contentId: contentId,
      contentType: 'ai_chat_response',
      contentUrlOrText: msg.text,
      onReportSubmitted: () {
        if (mounted) {
          setState(() {
            _isReported = true;
          });
        }
      },
    );
  }

  void _onReportImage(BuildContext context) {
    final msg = widget.message;
    final contentId = msg.wallpaper?.id ??
        'ai_img_${msg.timestamp?.millisecondsSinceEpoch ?? msg.imagePathOrUrl.hashCode}';

    ReportContentBottomSheet.show(
      context: context,
      contentId: contentId,
      contentType: 'ai_generated_wallpaper',
      contentUrlOrText: msg.imagePathOrUrl ?? '',
      contentPreviewImage: msg.imagePathOrUrl,
      onReportSubmitted: () {
        if (mounted) {
          setState(() {
            _isReported = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isUser = message.isUser;

    // If this content was reported, display safety placeholder banner
    if (_isReported && !isUser) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                color: Colors.redAccent,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'AI content reported & hidden from view',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final assistantBubbleBg =
        isDark ? const Color(0xFF161824) : AppColors.lightSurface;
    final assistantBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.08))
        : Border.all(color: AppColors.lightBorder);
    final textColor = isUser
        ? Colors.white
        : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);

    final hasImage = message.imagePathOrUrl != null &&
        message.imagePathOrUrl!.isNotEmpty;
    final isLocalImage = hasImage &&
        !message.imagePathOrUrl!.startsWith('http') &&
        File(message.imagePathOrUrl!).existsSync();

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      // Flag/Report button on AI text message
                      InkWell(
                        onTap: () => _onReportMessage(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                size: 13,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Report',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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

          // Generated Wallpaper Card Preview in chat
          if (!isUser && hasImage)
            GestureDetector(
              onTap: () {
                if (message.wallpaper != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WallpaperDetailScreen(wallpaper: message.wallpaper!),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(top: 4.0, bottom: 12.0, left: 4.0),
                width: 200,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      isLocalImage
                          ? Image.file(
                              File(message.imagePathOrUrl!),
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: message.imagePathOrUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: isDark
                                    ? const Color(0xFF141520)
                                    : Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade900,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),

                      // In-App Content Report Button on AI Image Card
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _onReportImage(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Report',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom "Tap to View & Apply" overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap to View & Apply',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Suggested Styles Quick Selection Chips
          if (!isUser &&
              message.suggestedStyles != null &&
              message.suggestedStyles!.isNotEmpty &&
              widget.onStyleTap != null)
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
                        onPressed: () => widget.onStyleTap!(style),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Prominent "✨ Re-Create Wallpaper" Action Button for AI Messages without direct image
          if (!isUser && message.optimizedPrompt != null && !hasImage)
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
                  onPressed: () => widget.onGenerateTap(message.optimizedPrompt!),
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
