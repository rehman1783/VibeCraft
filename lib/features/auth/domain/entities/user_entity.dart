// lib/features/auth/domain/entities/user_entity.dart
class UserEntity {
  final String uid;
  final String? email;
  final String? name;
  final bool isAnonymous;
  final bool isEmailVerified;

  const UserEntity({
    required this.uid,
    this.email,
    this.name,
    required this.isAnonymous,
    required this.isEmailVerified,
  });
}