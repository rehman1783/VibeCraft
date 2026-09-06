import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/utils/app_snackbar.dart';
import 'package:vibe_craft/core/widgets/report_content_bottom_sheet.dart';
import 'package:vibe_craft/features/wallpaper_explore/domain/entities/wallpaper_entity.dart';
import 'package:vibe_craft/features/wallpaper_explore/domain/repositories/wallpaper_repository.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:vibe_craft/injection_container.dart';

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
  bool _isApplying = false;

  bool get _isLocalFile =>
      !widget.imageUrl.startsWith('http') && File(widget.imageUrl).existsSync();

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

  Future<void> _onSetWallpaperPressed() async {
    if (_isApplying) return;

    WallpaperRepository repository;
    try {
      repository = context.read<WallpaperRepository>();
    } catch (_) {
      repository = sl<WallpaperRepository>();
    }

    setState(() {
      _isApplying = true;
    });

    try {
      final success = await repository.applyWallpaper(
        imagePathOrUrl: widget.imageUrl,
        target: WallpaperTarget.both,
      );

      if (mounted) {
        if (success) {
          AppSnackBar.showSuccess(
            context,
            'Wallpaper successfully applied to Home & Lock Screens!',
          );
        } else {
          AppSnackBar.showError(context, 'Failed to set wallpaper on device.');
        }
        setState(() {
          _isApplying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to set wallpaper: ${e.toString()}',
        );
        setState(() {
          _isApplying = false;
        });
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
          _isLocalFile
              ? Image.file(
                  File(widget.imageUrl),
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color:
                        isDark ? const Color(0xFF141520) : Colors.grey.shade900,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Loading 8K high-res preview...',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13),
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
                          Icon(
                            Icons.broken_image_rounded,
                            color: Colors.redAccent,
                            size: 48,
                          ),
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
                          'Gemini AI Masterpiece',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // In-App Content Report Button (Google Play AI Policy Compliance)
                  GestureDetector(
                    onTap: () {
                      ReportContentBottomSheet.show(
                        context: context,
                        contentId: 'ai_preview_${widget.imageUrl.hashCode}',
                        contentType: 'ai_generated_wallpaper',
                        contentUrlOrText: widget.imageUrl,
                        contentPreviewImage: widget.imageUrl,
                        onReportSubmitted: () {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
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
                        Icons.flag_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
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
                    Colors.black.withValues(alpha: 0.94),
                    Colors.black.withValues(alpha: 0.5),
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

                  // Action Buttons Row: Apply, Download, Regenerate
                  Row(
                    children: [
                      // Set Wallpaper Button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                _isApplying ? null : _onSetWallpaperPressed,
                            icon: _isApplying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.wallpaper_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                            label: Text(
                              _isApplying ? 'Applying...' : 'Apply',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

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
                            onPressed:
                                _isDownloading ? null : _onDownloadPressed,
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
                                    size: 19,
                                  ),
                            label: Text(
                              _isSaved ? 'Saved' : 'Save',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

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
                          child: const Center(
                            child: Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
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
