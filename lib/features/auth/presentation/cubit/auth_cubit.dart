// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wall_zen/features/auth/domain/repositories/auth_repository.dart';
import 'package:wall_zen/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const AuthError('Please enter both email and password.'));
      return;
    }
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      emit(const AuthError('Please fill all required fields.'));
      return;
    }
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      emit(const AuthError('Please enter your email address.'));
      return;
    }
    emit(AuthLoading());
    try {
      await authRepository.sendPasswordResetEmail(trimmedEmail);
      emit(PasswordResetEmailSent(trimmedEmail));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword({required String newPassword, String? oobCode}) async {
    if (newPassword.length < 6) {
      emit(const AuthError('Password must be at least 6 characters long.'));
      return;
    }
    emit(AuthLoading());
    try {
      await authRepository.resetPassword(newPassword: newPassword, oobCode: oobCode);
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(Unauthenticated());
  }
}