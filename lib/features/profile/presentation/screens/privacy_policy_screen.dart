import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/utils/app_snackbar.dart';
import 'package:vibe_craft/routes.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String supportEmail = 'abdulrehman78ali@gmail.com';

  void _copySupportEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: supportEmail));
    AppSnackBar.showSuccess(
      context,
      'Support email copied to clipboard: $supportEmail',
    );
  }

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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Policy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Data safety & governance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Policy Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Hero Banner Card
                    _buildHeroBanner(
                      isDark: isDark,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),

                    const SizedBox(height: 18),

                    // Section 01: Account Registration & Personal Data
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '01',
                      numberBadgeBg: const Color(0xFF281E45),
                      numberTextColor: const Color(0xFFB388FF),
                      title: 'Account Registration & Data',
                      body:
                          'VibeCraft collects minimal information strictly necessary to provide authenticated sync, personalized wallpapers, and profile management:',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          _buildBulletPoint(
                            boldTitle: 'Firebase Authentication: ',
                            bodyText:
                                'For Email/Password sign-ups, we store your chosen name and email address. Passwords are cryptographically hashed by Firebase and are never accessible in plain text.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFB388FF),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Google Sign-In: ',
                            bodyText:
                                'If you authenticate using Google, we securely receive your basic profile data (Name, Email, Avatar URL) via Google OAuth 2.0.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFB388FF),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Cloud Firestore Sync: ',
                            bodyText:
                                'Minimal user metadata (UID, display name, email, auth provider, creation timestamp) is synced to Firestore.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFB388FF),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Custom Profile Picture: ',
                            bodyText:
                                'You may optionally upload an avatar. Profile pictures are stored locally in private storage or linked to your Google account.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFB388FF),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 02: Storage & Permissions (Zero Gallery Access)
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '02',
                      numberBadgeBg: const Color(0xFF1E2445),
                      numberTextColor: const Color(0xFF8C9EFF),
                      title: 'Device Permissions & Storage',
                      body:
                          'VibeCraft is built with a strict privacy-first architecture to protect your personal files and device privacy.',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          // Green Privacy Highlight Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00E676,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(
                                  0xFF00E676,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  color: Color(0xFF00E676),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Zero Public Gallery Access: VibeCraft does NOT request, scan, read, or export data to your device\'s personal photo library.',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF1E293B),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildBulletPoint(
                            boldTitle: 'App-Private Storage: ',
                            bodyText:
                                'Downloaded wallpapers and cache files are saved exclusively in the app\'s isolated document directory.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFF8C9EFF),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'SET_WALLPAPER Permission: ',
                            bodyText:
                                'Enables direct application of wallpapers to Home Screen, Lock Screen, or Both without needing external file manager access.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFF8C9EFF),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Network Permissions: ',
                            bodyText:
                                'INTERNET & ACCESS_NETWORK_STATE are used exclusively to fetch wallpapers, AI generations, and verify connectivity.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFF8C9EFF),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 03: AI Creator & Google Gemini
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '03',
                      numberBadgeBg: const Color(0xFF381F4A),
                      numberTextColor: const Color(0xFFE040FB),
                      title: 'AI Creator & Gemini AI',
                      body:
                          'VibeCraft offers an AI-powered Wallpaper Creator feature powered by advanced generative AI technology:',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          _buildBulletPoint(
                            boldTitle: 'Google Gemini AI: ',
                            bodyText:
                                'The AI Creator feature uses Google Gemini AI models to generate prompt expansions, creative styles, and visual prompts.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFE040FB),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Anonymized Requests: ',
                            bodyText:
                                'Text prompts submitted for AI generation are processed anonymously and are never associated with your personal identity or credentials.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFE040FB),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 04: Third-Party Integrations
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '04',
                      numberBadgeBg: const Color(0xFF3B321A),
                      numberTextColor: const Color(0xFFFFD54F),
                      title: 'Third-Party Services',
                      body:
                          'We integrate with industry-leading providers to deliver high-quality wallpapers and secure cloud infrastructure:',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 340;
                              if (isNarrow) {
                                return Column(
                                  children: [
                                    _buildProviderBox(
                                      icon: Icons.cloud_outlined,
                                      categoryLabel: 'INFRASTRUCTURE',
                                      nameText: 'Google Firebase',
                                      descText: 'Auth & Cloud Firestore sync',
                                      isDark: isDark,
                                      borderColor: borderColor,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildProviderBox(
                                      icon: Icons.auto_awesome_rounded,
                                      categoryLabel: 'AI ENGINE',
                                      nameText: 'Google Gemini AI',
                                      descText: 'AI wallpaper generator',
                                      isDark: isDark,
                                      borderColor: borderColor,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildProviderBox(
                                      icon: Icons.photo_library_outlined,
                                      categoryLabel: 'CATALOG',
                                      nameText: 'Unsplash & Pixabay',
                                      descText: 'Curated wallpaper discovery',
                                      isDark: isDark,
                                      borderColor: borderColor,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildProviderBox(
                                      icon: Icons.fingerprint_rounded,
                                      categoryLabel: 'SECURITY',
                                      nameText: 'Google OAuth',
                                      descText: 'One-tap secure login',
                                      isDark: isDark,
                                      borderColor: borderColor,
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildProviderBox(
                                          icon: Icons.cloud_outlined,
                                          categoryLabel: 'INFRASTRUCTURE',
                                          nameText: 'Google Firebase',
                                          descText: 'Auth & Firestore',
                                          isDark: isDark,
                                          borderColor: borderColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildProviderBox(
                                          icon: Icons.auto_awesome_rounded,
                                          categoryLabel: 'AI ENGINE',
                                          nameText: 'Gemini AI',
                                          descText: 'AI Generator',
                                          isDark: isDark,
                                          borderColor: borderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildProviderBox(
                                          icon: Icons.photo_library_outlined,
                                          categoryLabel: 'CATALOG',
                                          nameText: 'Unsplash / Pixabay',
                                          descText: 'Curated Wallpapers',
                                          isDark: isDark,
                                          borderColor: borderColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildProviderBox(
                                          icon: Icons.fingerprint_rounded,
                                          categoryLabel: 'SECURITY',
                                          nameText: 'Google OAuth',
                                          descText: 'Secure Sign-In',
                                          isDark: isDark,
                                          borderColor: borderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 05: Data Retention & Instant Account Deletion
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '05',
                      numberBadgeBg: const Color(0xFF38151D),
                      numberTextColor: const Color(0xFFFF5252),
                      title: 'Data Retention & Deletion',
                      body:
                          'You have full autonomy over your data. When you delete your account, your personal information and local application cache are immediately and permanently erased.',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          _buildBulletPoint(
                            boldTitle: 'Permanent Wipe: ',
                            bodyText:
                                'Removes your Firebase Auth account, Firestore profile, downloaded wallpapers, favorites, and settings.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFFF5252),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Web Portal Available: ',
                            bodyText:
                                'Google Play compliant web deletion is also available via email if you have uninstalled the app.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFFFF5252),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(
                                    0xFFFF2B50,
                                  ).withValues(alpha: 0.5),
                                ),
                                backgroundColor: const Color(
                                  0xFFFF2B50,
                                ).withValues(alpha: 0.08),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 14,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.deleteAccount);
                              },
                              icon: const Icon(
                                Icons.delete_forever_rounded,
                                color: Color(0xFFFF5252),
                                size: 18,
                              ),
                              label: const Text(
                                'Manage Account & Data Deletion',
                                style: TextStyle(
                                  color: Color(0xFFFF5252),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 06: User Rights & GDPR / CCPA
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '06',
                      numberBadgeBg: const Color(0xFF192E38),
                      numberTextColor: const Color(0xFF00E5FF),
                      title: 'User Rights & Compliance',
                      body:
                          'In adherence with global data protection frameworks (including GDPR, CCPA, and Google Play Data Safety policies), you retain the following rights:',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      customBottomContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          _buildBulletPoint(
                            boldTitle: 'Right to Access & Edit: ',
                            bodyText:
                                'View or modify your display name and avatar at any time in Profile settings.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFF00E5FF),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Right to Erasure: ',
                            bodyText:
                                'Permanently delete your profile and wipe local data with one click.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFF00E5FF),
                          ),
                          _buildBulletPoint(
                            boldTitle: 'Clear Cache Tool: ',
                            bodyText:
                                'Free device storage by clearing cached wallpapers in Profile settings without losing your account.',
                            subtitleColor: subtitleColor,
                            accentColor: const Color(0xFF00E5FF),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 07: Children's Privacy (COPPA)
                    _buildPolicySectionCard(
                      context: context,
                      numberText: '07',
                      numberBadgeBg: const Color(0xFF28281E),
                      numberTextColor: const Color(0xFFFFEE58),
                      title: 'Children\'s Privacy',
                      body:
                          'VibeCraft is intended for general audiences and does not knowingly collect or solicit personal information from children under the age of 13. If you believe a child has provided personal information, contact us for immediate deletion.',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),

                    const SizedBox(height: 16),

                    // Section 08: Support & Contact Card
                    Container(
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
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8B3CFF,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.support_agent_rounded,
                                    color: Color(0xFFA855F7),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Contact & Support',
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
                            'If you have questions, feedback, or inquiries regarding this Privacy Policy or your personal data:',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF38BDF8),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    supportEmail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B3CFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () => _copySupportEmail(context),
                              icon: const Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Copy Support Email',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer text
                    Text(
                      '© 2026 VibeCraft App. All rights reserved.\nCompliant with Google Play Data Safety policies.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor.withValues(alpha: 0.7),
                        fontSize: 11.5,
                        height: 1.5,
                      ),
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

  Widget _buildHeroBanner({
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2B1848), const Color(0xFF13101F)]
              : [const Color(0xFFEFE4FF), const Color(0xFFF7F2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF8B3CFF).withValues(alpha: 0.25),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: const Color(0xFF8B3CFF).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B3CFF), Color(0xFF651FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B3CFF).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF00E676),
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'POLICY COMPLIANT',
                      style: TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'VibeCraft',
            style: TextStyle(
              color: titleColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Legal & Privacy Policy',
            style: TextStyle(
              color: Color(0xFF9D54FF),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your AI-powered wallpaper studio. We prioritize user privacy with an isolated, zero-gallery-intrusion storage model.',
            style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.45),
          ),

          const SizedBox(height: 16),

          // Compliance Badges Wrap (Scales dynamically on all screens)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPillTag(
                icon: Icons.shield_outlined,
                label: 'Zero Gallery Access',
                isDark: isDark,
              ),
              _buildPillTag(
                icon: Icons.lock_outline_rounded,
                label: 'TLS 1.3 Encrypted',
                isDark: isDark,
              ),
              _buildPillTag(
                icon: Icons.schedule_rounded,
                label: 'Updated: Aug 2026',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFB388FF), size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: numberBadgeBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    numberText,
                    style: TextStyle(
                      color: numberTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          ?customBottomContent,
        ],
      ),
    );
  }

  Widget _buildBulletPoint({
    required String boldTitle,
    required String bodyText,
    required Color subtitleColor,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: boldTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: bodyText),
                ],
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
    required String descText,
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
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  categoryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
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
          const SizedBox(height: 2),
          Text(
            descText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
