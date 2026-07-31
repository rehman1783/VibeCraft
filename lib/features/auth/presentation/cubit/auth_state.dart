// lib/features/auth/presentation/cubit/auth_state.dart
import 'package:vibe_craft/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class PasswordResetEmailSent extends AuthState {
  final String email;
  const PasswordResetEmailSent(this.email);
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}
