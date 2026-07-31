// lib/features/auth/data/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wall_zen/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.name,
    required super.isAnonymous,
    required super.isEmailVerified,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      isAnonymous: user.isAnonymous,
      isEmailVerified: user.emailVerified,
    );
  }
}