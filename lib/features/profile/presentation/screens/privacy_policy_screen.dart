import 'package:flutter/material.dart';
import 'package:wall_zen/core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final surface = isDark ? AppColors.surface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Privacy Policy & Terms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: surface,
                  border: isDark
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        )
                      : Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WallZen Privacy Policy & Terms',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Google Play Compliant • Effective: July 2026',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                title: '1. Minimal Data Collection',
                body:
                    'WallZen respects user privacy. We collect minimal account data (display name and email address) exclusively when you authenticate via Firebase Authentication. We do not track location, device contacts, or sell personal data to third parties.',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surface: surface,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              _buildSection(
                title: '2. App-Private Storage Policy (Zero Gallery Access)',
                body:
                    'All downloaded wallpapers are saved strictly inside the app\'s isolated private document directory. WallZen does NOT request, read, or export data to your device\'s public media gallery or external photos library, guaranteeing zero photo library pollution.',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surface: surface,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              _buildSection(
                title: '3. Third-Party Integrations & Services',
                body:
                    'WallZen integrates with trusted third-party providers:\n'
                    '• Unsplash REST API: Used to fetch high-resolution wallpaper imagery and report download telemetry per Unsplash API Guidelines.\n'
                    '• Firebase (Auth & Firestore): Used for secure authentication and cross-device favorites synchronization.',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surface: surface,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              _buildSection(
                title: '4. Local Cache & 100MB Storage Cap',
                body:
                    'To optimize device performance, WallZen enforces an automatic 100 MB local storage cap for downloaded wallpapers (First-In, First-Out auto-pruning). Users may also perform a full data wipe at any time via "Clear Cache" in Profile settings.',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surface: surface,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              _buildSection(
                title: '5. Account Deletion & Right to be Forgotten',
                body:
                    'In compliance with Google Play Store User Data policies, users can permanently delete their account and associated Cloud Firestore data at any time via the "Delete Account" button in Profile settings.',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surface: surface,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              _buildSection(
                title: '6. Support & Contact',
                body:
                    'For questions, privacy inquiries, or support, please contact our team at abdulrehman78ali@gmail.com',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                surface: surface,
                isDark: isDark,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String body,
    required Color textPrimary,
    required Color textSecondary,
    required Color surface,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: surface,
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.05))
            : Border.all(color: AppColors.lightBorder.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
