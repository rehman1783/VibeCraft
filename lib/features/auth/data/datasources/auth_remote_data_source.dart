// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vibe_craft/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> syncUserProfile(User user, {String? name});
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
  Future<bool> isEmailRegistered(String email);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> resetPassword({required String newPassword, String? oobCode});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  bool _isValidEmailFormat(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );
    if (!emailRegex.hasMatch(email)) return false;
    final parts = email.split('@');
    if (parts.length != 2) return false;
    final domain = parts[1];
    if (!domain.contains('.')) return false;
    return domain.split('.').last.length >= 2;
  }

  Future<bool> _isEmailDomainValid(String email) async {
    final trimmed = email.trim();
    if (!_isValidEmailFormat(trimmed)) return false;
    final domain = trimmed.split('@')[1].toLowerCase().trim();

    try {
      final addresses = await InternetAddress.lookup(domain);
      return addresses.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> syncUserProfile(User user, {String? name}) async {
    final docRef = firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    final Map<String, dynamic> data = {
      'uid': user.uid,
      'email': user.email ?? '',
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      data['photoURL'] = user.photoURL;
    }

    if (name != null && name.isNotEmpty) {
      data['displayName'] = name;
    } else if (user.displayName != null && user.displayName!.isNotEmpty) {
      data['displayName'] = user.displayName;
    }

    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';
    data['authProvider'] = providerId;

    if (!docSnapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(data, SetOptions(merge: true));
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId:
          '197785385774-ph777n6rkp2fhb6kcdj51mpb2r01clko.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Google sign in aborted by user.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Google Sign-In failed to retrieve user account.',
      );
    }

    await syncUserProfile(user, name: user.displayName);
    return UserModel.fromFirebase(user);
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();

    // 1. Check if user email is registered in Firestore users collection FIRST
    bool emailExistsInFirestore = false;
    try {
      final userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: trimmedEmail)
          .limit(1)
          .get();
      emailExistsInFirestore = userQuery.docs.isNotEmpty;

      if (!emailExistsInFirestore) {
        final lowerQuery = await firestore
            .collection('users')
            .where('email', isEqualTo: trimmedEmail.toLowerCase())
            .limit(1)
            .get();
        emailExistsInFirestore = lowerQuery.docs.isNotEmpty;
      }
    } catch (_) {
      // If query fails, default to false so unregistered user gets prompt
      emailExistsInFirestore = false;
    }

    if (!emailExistsInFirestore) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'User does not have any account. Please sign up first.',
      );
    }

    // 2. Email IS registered! Now authenticate password in Firebase Auth
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = credential.user!;
      await syncUserProfile(user);
      return UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'user-not-found') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Incorrect password. Please enter the correct password.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();

    final isValidDomain = await _isEmailDomainValid(trimmedEmail);
    if (!isValidDomain) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message:
            'This email domain does not exist. Please enter a valid, active email address.',
      );
    }

    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name);

      await syncUserProfile(user, name: name);

      return UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message:
              'This email does not exist. Please enter a valid, active email address.',
        );
      } else if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message:
              'An account with this email already exists. Please login instead.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    final trimmedEmail = email.trim();
    if (!_isValidEmailFormat(trimmedEmail)) {
      return false;
    }

    try {
      final userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: trimmedEmail)
          .limit(1)
          .get();
      if (userQuery.docs.isNotEmpty) {
        return true;
      }

      final lowerQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: trimmedEmail.toLowerCase())
          .limit(1)
          .get();
      return lowerQuery.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();
    if (!_isValidEmailFormat(trimmedEmail)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter a valid email address.',
      );
    }

    // 1. Check if email is registered in Firestore users collection (same verification as login)
    final isRegistered = await isEmailRegistered(trimmedEmail);
    if (!isRegistered) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found with this email address.',
      );
    }

    // 2. Send password reset email via Firebase Auth
    try {
      await firebaseAuth.sendPasswordResetEmail(email: trimmedEmail);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found with this email address.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String newPassword,
    String? oobCode,
  }) async {
    if (oobCode != null && oobCode.isNotEmpty) {
      await firebaseAuth.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
    } else {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
        await firestore.collection('users').doc(currentUser.uid).set({
          'updatedAt': FieldValue.serverTimestamp(),
          'lastPasswordResetAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        throw FirebaseAuthException(
          code: 'no-user',
          message:
              'Unable to update password. Please use the reset link sent to your email.',
        );
      }
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await firebaseAuth.signOut();
  }
}

