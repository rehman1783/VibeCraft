// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';
import 'package:vibe_craft/core/widgets/vibe_button.dart';
import 'package:vibe_craft/core/widgets/vibe_text_field.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_state.dart';
import 'package:vibe_craft/features/auth/presentation/widgets/auth_header.dart';
import 'package:vibe_craft/features/auth/presentation/widgets/forgot_password_dialog.dart';
import 'package:vibe_craft/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    context.read<AuthCubit>().loginWithEmail(email, password);
  }

  void _onForgotPasswordPressed() {
    showDialog(context: context, builder: (_) => const ForgotPasswordDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
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
                // 1. Full Login Form (Always visible)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const AuthHeader(
                        title: 'WELCOME BACK',
                        subtitle:
                            'Sign in to access your saved wallpapers & AI Studio',
                      ),
                      const SizedBox(height: 36),
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
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: isLoading ? null : _onForgotPasswordPressed,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      VibeButton(
                        label: 'Login',
                        onPressed: isLoading ? () {} : _onLoginPressed,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
                            child: const Text(
                              'Sign Up',
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
                              'Authenticating...',
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
