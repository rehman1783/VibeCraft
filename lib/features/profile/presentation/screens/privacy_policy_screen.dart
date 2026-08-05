import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0C0E14) : const Color(0xFFF6F7FB);
    final cardBg = isDark ? const Color(0xFF131520) : const Color(0xFFFFFFFF);
    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar Navigation Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: titleColor,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Privacy & Terms',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Policy Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Banner Hero Card: VibeCraft Legal Policy
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF2B1848),
                                  const Color(0xFF13101F),
                                ]
                              : [
                                  const Color(0xFFEFE4FF),
                                  const Color(0xFFF7F2FF),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFF8B3CFF).withValues(alpha: 0.25),
                        ),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF8B3CFF)
                                      .withValues(alpha: 0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Purple Shield Icon Box
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B3CFF), Color(0xFF651FFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B3CFF)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'VibeCraft',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Legal Policy',
                            style: TextStyle(
                              color: Color(0xFF9D54FF),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Footer Wrap/Row of Hero Card
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF00E676)
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: const Text(
                                  'GOOGLE PLAY COMPLIANT',
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Text(
                                'Effective: July 2026',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 01: Minimal Data Collection
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '01',
                      numberBadgeBg: const Color(0xFF281E45),
                      numberTextColor: const Color(0xFFB388FF),
                      title: 'Minimal Data Collection',
                      body:
                          'VibeCraft respects user privacy. We collect minimal account data (display name and email address) exclusively when you authenticate via Firebase Authentication.',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Wrap(
                            direction: Axis.vertical,
                            spacing: 8,
                            children: [
                              _buildRestrictionPill(
                                icon: Icons.location_off_outlined,
                                label: 'No Location Tracking',
                                isDark: isDark,
                              ),
                              _buildRestrictionPill(
                                icon: Icons.no_accounts_outlined,
                                label: 'No Contact Access',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 02: App-Private Storage Policy
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '02',
                      numberBadgeBg: const Color(0xFF1E2445),
                      numberTextColor: const Color(0xFF8C9EFF),
                      title: 'App-Private Storage Policy',
                      body:
                          "All downloaded wallpapers are saved strictly inside the app's isolated private document directory.",
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF191728)
                                  : const Color(0xFFF3EDFF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF8B3CFF)
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lock_rounded,
                                  color: Color(0xFF9D54FF),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 13,
                                        height: 1.45,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'VibeCraft does ',
                                        ),
                                        TextSpan(
                                          text: 'NOT',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF9D54FF),
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' request, read, or export data to your device\'s public media gallery, guaranteeing zero photo library pollution.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 03: Third-Party Integrations
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '03',
                      numberBadgeBg: const Color(0xFF3B321A),
                      numberTextColor: const Color(0xFFFFD54F),
                      title: 'Third-Party Integrations',
                      body:
                          'We partner with industry-leading providers to ensure a secure and seamless wallpaper experience. Your data remains encrypted at all stages.',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProviderBox(
                                  icon: Icons.cloud_outlined,
                                  categoryLabel: 'INFRASTRUCTURE',
                                  nameText: 'Firebase Auth',
                                  isDark: isDark,
                                  borderColor: borderColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildProviderBox(
                                  icon: Icons.bar_chart_rounded,
                                  categoryLabel: 'PERFORMANCE',
                                  nameText: 'Cloud Metrics',
                                  isDark: isDark,
                                  borderColor: borderColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Footer Disclaimer Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'By using VibeCraft, you agree to these terms. We may update this policy occasionally to reflect service changes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Footer Quick Links Row (Wrap used to eliminate any horizontal overflow)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Text(
                          'Support',
                          style: TextStyle(
                            color: titleColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Help Center',
                          style: TextStyle(
                            color: titleColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Privacy FAQ',
                          style: TextStyle(
                            color: titleColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySectionCard({
    required BuildContext context,
    required String numberText,
    required Color numberBadgeBg,
    required Color numberTextColor,
    required String title,
    required String body,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    Widget? customBottomContent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: numberBadgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    numberText,
                    style: TextStyle(
                      color: numberTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          ?customBottomContent,
        ],
      ),
    );
  }

  Widget _buildRestrictionPill({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1A24) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF5252),
            size: 15,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderBox({
    required IconData icon,
    required String categoryLabel,
    required String nameText,
    required bool isDark,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191B26) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            nameText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
