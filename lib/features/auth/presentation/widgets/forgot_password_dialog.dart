// lib/features/auth/presentation/widgets/forgot_password_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/widgets/vibe_button.dart';
import 'package:vibe_craft/core/widgets/vibe_text_field.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_state.dart';
import 'package:vibe_craft/routes.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter your registered email address.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.secondary.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
      );
      return;
    }

    context.read<AuthCubit>().sendPasswordResetEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is PasswordResetEmailSent) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushNamed(
                    context,
                    AppRoutes.forgotPasswordSent,
                    arguments: state.email,
                  );
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.secondary.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FORGOT PASSWORD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your registered email address to receive a password reset link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    VibeTextField(
                      controller: _emailController,
                      hintText: 'Registered Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: VibeButton(
                            label: 'Continue',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _onContinuePressed,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
