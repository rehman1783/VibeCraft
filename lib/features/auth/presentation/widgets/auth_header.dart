import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}