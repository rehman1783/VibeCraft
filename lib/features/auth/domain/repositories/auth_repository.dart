// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:wall_zen/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<UserEntity?> getCurrentUser();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> resetPassword({required String newPassword, String? oobCode});
}