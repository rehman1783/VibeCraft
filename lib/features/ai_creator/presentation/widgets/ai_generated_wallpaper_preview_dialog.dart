import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/utils/app_snackbar.dart';
import 'package:vibe_craft/features/wallpaper_explore/domain/entities/wallpaper_entity.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';

class AiGeneratedWallpaperPreviewDialog extends StatefulWidget {
  final String imageUrl;
  final String prompt;
  final VoidCallback onRegenerate;

  const AiGeneratedWallpaperPreviewDialog({
    super.key,
    required this.imageUrl,
    required this.prompt,
    required this.onRegenerate,
  });

  static Future<void> show({
    required BuildContext context,
    required String imageUrl,
    required String prompt,
    required VoidCallback onRegenerate,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AiGeneratedWallpaperPreviewDialog(
        imageUrl: imageUrl,
        prompt: prompt,
        onRegenerate: onRegenerate,
      ),
    );
  }

  @override
  State<AiGeneratedWallpaperPreviewDialog> createState() =>
      _AiGeneratedWallpaperPreviewDialogState();
}

class _AiGeneratedWallpaperPreviewDialogState
    extends State<AiGeneratedWallpaperPreviewDialog> {
  bool _isDownloading = false;
  bool _isSaved = false;

  Future<void> _onDownloadPressed() async {
    if (_isDownloading || _isSaved) return;

    setState(() {
      _isDownloading = true;
    });

    final aiWallpaper = WallpaperEntity(
      id: 'ai_gen_${DateTime.now().millisecondsSinceEpoch}',
      thumbnailUrl: widget.imageUrl,
      highResUrl: widget.imageUrl,
      rawUrl: widget.imageUrl,
      photographer: 'VibeCraft AI Studio',
      photographerUsername: 'vibecraft_ai',
      altDescription: widget.prompt,
      color: '#8B3CFF',
      likes: 1,
      width: 1080,
      height: 1920,
    );

    try {
      await context.read<WallpaperCubit>().downloadWallpaper(aiWallpaper);
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isSaved = true;
        });
        AppSnackBar.showSuccess(
          context,
          'Wallpaper saved to My Downloads!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        AppSnackBar.showError(
          context,
          'Failed to save wallpaper. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog.fullscreen(
      backgroundColor: isDark ? const Color(0xFF0B0813) : Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High Resolution Vertical Wallpaper Image
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: isDark ? const Color(0xFF141520) : Colors.grey.shade900,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Loading high-res preview...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image_rounded,
                        color: Colors.redAccent, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Failed to load generated image preview',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Top Bar with Close Button & Title Badge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AI Generated Art',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40), // Balance top row
                ],
              ),
            ),
          ),

          // 3. Bottom Control Action Bar Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.92),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prompt Text Caption
                  Text(
                    widget.prompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Row: Download & Regenerate
                  Row(
                    children: [
                      // Download Wallpaper Button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSaved
                                  ? const Color(0xFF00E676)
                                  : AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isDownloading ? null : _onDownloadPressed,
                            icon: _isDownloading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isSaved
                                        ? Icons.check_circle_rounded
                                        : Icons.download_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            label: Text(
                              _isSaved
                                  ? 'Saved to Downloads'
                                  : 'Download Wallpaper',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Regenerate Button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onRegenerate();
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
