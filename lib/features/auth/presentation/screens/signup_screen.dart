// lib/features/auth/presentation/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/widgets/vibe_button.dart';
import 'package:vibe_craft/core/widgets/vibe_text_field.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_state.dart';
import 'package:vibe_craft/features/auth/presentation/widgets/auth_header.dart';
import 'package:vibe_craft/routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill in all required fields.',
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
              color: Colors.orangeAccent.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Passwords do not match. Please re-enter.',
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

    context.read<AuthCubit>().signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
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

          return SafeArea(
            child: Stack(
              children: [
                // 1. Full Signup Form (Always visible)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'CREATE ACCOUNT',
                        subtitle:
                            'Join WallZen to unlock full AI creation capabilities',
                      ),
                      const SizedBox(height: 32),
                      VibeTextField(
                        controller: _nameController,
                        hintText: 'Full Name',
                      ),
                      const SizedBox(height: 16),
                      VibeTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      VibeTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      VibeTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        isPassword: true,
                      ),
                      const SizedBox(height: 28),
                      VibeButton(
                        label: 'Sign Up',
                        onPressed: isLoading ? () {} : _onSignUpPressed,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Non-blocking Translucent Loading Overlay
                if (isLoading)
                  Container(
                    color: Colors.black45,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text(
                              'Creating Account...',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
