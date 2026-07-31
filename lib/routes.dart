import 'package:flutter/material.dart';
import 'package:wall_zen/features/auth/presentation/screens/forgot_password_sent_screen.dart';
import 'package:wall_zen/features/auth/presentation/screens/login_screen.dart';
import 'package:wall_zen/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:wall_zen/features/auth/presentation/screens/signup_screen.dart';
import 'package:wall_zen/features/auth/presentation/screens/splash_screen.dart';
import 'package:wall_zen/features/navigation/presentation/screens/main_screen.dart';
import 'package:wall_zen/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:wall_zen/features/wallpaper_explore/domain/entities/wallpaper_entity.dart';
import 'package:wall_zen/features/wallpaper_explore/presentation/screens/wallpaper_detail_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String forgotPasswordSent = '/forgot-password-sent';
  static const String resetPassword = '/reset-password';
  static const String privacyPolicy = '/privacy-policy';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case detail:
        final wallpaper = settings.arguments as WallpaperEntity;
        return MaterialPageRoute(
          builder: (_) => WallpaperDetailScreen(wallpaper: wallpaper),
        );

      case forgotPasswordSent:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordSentScreen(email: email),
        );

      case resetPassword:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        );

      case privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route error: Screen not found')),
          ),
        );
    }
  }
}
