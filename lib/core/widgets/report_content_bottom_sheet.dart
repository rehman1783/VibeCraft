import 'package:flutter/material.dart';
import '../models/report_content_model.dart';
import '../services/content_report_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../../injection_container.dart';

/// Modal bottom sheet for reporting offensive AI-generated or uploaded content.
/// Complies with Google Play's AI-Generated Content reporting policy.
class ReportContentBottomSheet extends StatefulWidget {
  final String contentId;
  final String contentType; // 'ai_generated_wallpaper', 'ai_chat_response', 'wallpaper'
  final String contentUrlOrText;
  final String? contentPreviewImage;
  final VoidCallback? onReportSubmitted;

  const ReportContentBottomSheet({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentUrlOrText,
    this.contentPreviewImage,
    this.onReportSubmitted,
  });

  static Future<void> show({
    required BuildContext context,
    required String contentId,
    required String contentType,
    required String contentUrlOrText,
    String? contentPreviewImage,
    VoidCallback? onReportSubmitted,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportContentBottomSheet(
        contentId: contentId,
        contentType: contentType,
        contentUrlOrText: contentUrlOrText,
        contentPreviewImage: contentPreviewImage,
        onReportSubmitted: onReportSubmitted,
      ),
    );
  }

  @override
  State<ReportContentBottomSheet> createState() =>
      _ReportContentBottomSheetState();
}

class _ReportContentBottomSheetState extends State<ReportContentBottomSheet> {
  ReportReason _selectedReason = ReportReason.nsfwSexual;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  IconData _getIconForReason(ReportReason reason) {
    switch (reason) {
      case ReportReason.nsfwSexual:
        return Icons.explicit_rounded;
      case ReportReason.violenceGore:
        return Icons.warning_amber_rounded;
      case ReportReason.hateSpeech:
        return Icons.sentiment_very_dissatisfied_rounded;
      case ReportReason.selfHarmIllegal:
        return Icons.block_rounded;
      case ReportReason.copyrightInfringement:
        return Icons.copyright_rounded;
      case ReportReason.spamMisleading:
        return Icons.auto_fix_off_rounded;
      case ReportReason.other:
        return Icons.more_horiz_rounded;
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final service = sl<ContentReportService>();
    final success = await service.submitReport(
      contentId: widget.contentId,
      contentType: widget.contentType,
      contentUrlOrText: widget.contentUrlOrText,
      reason: _selectedReason.label,
      details: _detailsController.text.trim().isNotEmpty
          ? _detailsController.text.trim()
          : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.of(context).pop();

    if (success) {
      widget.onReportSubmitted?.call();
      AppSnackBar.showSuccess(
        context,
        'Report submitted. Thank you for keeping VibeCraft safe. Our team reviews all flagged content within 24 hours.',
      );
    } else {
      AppSnackBar.showError(
        context,
        'Failed to submit report. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    final sheetBg = isDark ? const Color(0xFF131522) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1C1E2E) : const Color(0xFFF3F4F6);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Offensive Content',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Help us maintain a safe community',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable reasons & details
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHY ARE YOU REPORTING THIS?',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reason options list
                  ...ReportReason.values.map((reason) {
                    final isSelected = _selectedReason == reason;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedReason = reason;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getIconForReason(reason),
                                size: 20,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  reason.label,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Additional Details Input
                  Text(
                    'ADDITIONAL DETAILS (OPTIONAL)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    maxLength: 300,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Describe why this AI generation or content is offensive or violates policy...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Google Play Policy Compliance Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reports are immediately flagged for human moderation. Offensive material is permanently removed to comply with Google Play safety standards.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Report',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
