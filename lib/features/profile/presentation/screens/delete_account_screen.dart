import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/utils/app_snackbar.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibe_craft/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vibe_craft/features/profile/presentation/cubit/profile_state.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onDeletePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final password = _passwordController.text.trim();
    context.read<ProfileCubit>().deleteAccount(password: password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';
    final rawHandle = user?.displayName ??
        (userEmail.contains('@') ? userEmail.split('@').first : 'user');
    final cleanHandle = rawHandle.replaceAll(' ', '').toLowerCase();
    final handleText = '@$cleanHandle';

    final bgBackgroundColor =
        isDark ? const Color(0xFF0C0E14) : const Color(0xFFF6F7FB);
    final cardBgColor =
        isDark ? const Color(0xFF151822) : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is AccountDeletedSuccess) {
          AppSnackBar.showInfo(context, 'Your account has been deleted.');
          context.read<AuthCubit>().logout();
        } else if (state is ReauthRequired) {
          AppSnackBar.showError(context, state.message);
        } else if (state is ProfileError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: bgBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top Navigation Header
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
                          color: cardBgColor,
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
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Scrollable View
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // Red Warning Icon Container
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A151C),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFFF2B50).withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF2B50).withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFF2B50),
                              size: 42,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title: Are you absolutely sure?
                        Text(
                          'Are you absolutely sure?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'This action is irreversible. All your data will be permanently erased from the VibeCraft servers.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Card: YOU WILL LOSE ACCESS TO:
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOU WILL LOSE ACCESS TO:',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Item 1: Personal Wallpapers
                              _buildAccessLossItem(
                                context: context,
                                icon: Icons.image_outlined,
                                title: 'Personal Wallpapers',
                                subtitle: 'Over 124 custom generated designs',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 14),

                              // Item 2: Favorites & Collections
                              _buildAccessLossItem(
                                context: context,
                                icon: Icons.favorite_outline_rounded,
                                title: 'Favorites & Collections',
                                subtitle: 'All curated boards and liked assets',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 14),

                              // Item 3: Profile Identity
                              _buildAccessLossItem(
                                context: context,
                                icon: Icons.badge_outlined,
                                title: 'Profile Identity',
                                subtitle: 'Your unique handle $handleText and stats',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Password Field Label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter your password to confirm',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Password TextField
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: titleColor, fontSize: 15),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Password is required to confirm deletion';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(
                              color: subtitleColor.withValues(alpha: 0.5),
                              fontSize: 18,
                              letterSpacing: 2.0,
                            ),
                            filled: true,
                            fillColor: cardBgColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: subtitleColor,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF2B50),
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Primary Action Button: Delete Permanently
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            final isLoading = state is ProfileUpdating;

                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF2B50),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: isLoading ? null : _onDeletePressed,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Delete Permanently',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Secondary Action Button: Cancel
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: cardBgColor,
                              foregroundColor: titleColor,
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Disclaimer Footer
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'BY CLICKING DELETE, YOU ACKNOWLEDGE THAT VIBECRAFT CANNOT RECOVER YOUR ACCOUNT ONCE THE PROCESS IS COMPLETE.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.35),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessLossItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subtitleColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final iconBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: subtitleColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
