import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_craft/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final ImagePicker _imagePicker;

  ProfileCubit({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    ImagePicker? imagePicker,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(ProfileInitial());

  Future<void> fetchUserProfile() async {
    emit(ProfileLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const ProfileError('No authenticated user found.'));
        return;
      }

      String displayName = user.displayName ?? '';
      String email = user.email ?? '';

      // Read local profile photo path if exists
      final prefs = await SharedPreferences.getInstance();
      String? localPhotoPath = prefs.getString(
        'local_profile_photo_path_${user.uid}',
      );
      if (localPhotoPath != null && !File(localPhotoPath).existsSync()) {
        localPhotoPath = null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('displayName') &&
            data['displayName'] != null &&
            (data['displayName'] as String).isNotEmpty) {
          displayName = data['displayName'] as String;
        }
        if (data.containsKey('email') &&
            data['email'] != null &&
            (data['email'] as String).isNotEmpty) {
          email = data['email'] as String;
        }
      }

      if (displayName.isEmpty) {
        displayName = email.isNotEmpty ? email.split('@').first : 'User';
      }

      emit(
        ProfileLoaded(
          uid: user.uid,
          displayName: displayName,
          email: email,
          photoUrl: user.photoURL,
          localPhotoPath: localPhotoPath,
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateDisplayName(String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      emit(const ProfileError('Display name cannot be empty.'));
      return;
    }

    emit(ProfileUpdating());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const ProfileError('No authenticated user found.'));
        return;
      }

      if (trimmedName != user.displayName) {
        await user.updateDisplayName(trimmedName);
      }

      await _firestore.collection('users').doc(user.uid).set({
        'displayName': trimmedName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(const ProfileUpdateSuccess('Display name updated successfully!'));
      await fetchUserProfile();
    } on FirebaseAuthException catch (e) {
      emit(ProfileError(e.message ?? 'Failed to update display name.'));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> pickAndSaveAvatar() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return; // User cancelled image selection

      emit(ProfileUpdating());

      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'avatar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'local_profile_photo_path_${user.uid}',
        savedFile.path,
      );

      emit(const ProfileUpdateSuccess('Profile photo updated successfully!'));
      await fetchUserProfile();
    } catch (e) {
      emit(ProfileError('Failed to pick avatar: ${e.toString()}'));
    }
  }

  Future<void> clearCache() async {
    emit(ProfileUpdating());
    try {
      // 1. Clear Flutter RAM image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 2. Clear Temporary Directory
      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          final tempFiles = tempDir.listSync();
          for (final entity in tempFiles) {
            try {
              if (entity is File) {
                await entity.delete();
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
              }
            } catch (_) {}
          }
        }
      } catch (_) {}

      // 3. Clear App Documents Directory (wallpapers & local avatar files)
      try {
        final appDir = await getApplicationDocumentsDirectory();
        if (await appDir.exists()) {
          final appEntities = appDir.listSync();
          for (final entity in appEntities) {
            try {
              if (entity is File) {
                await entity.delete();
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
              }
            } catch (_) {}
          }
        }
      } catch (_) {}

      // 4. Total SharedPreferences Wipe
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      emit(
        const CacheClearedSuccess(
          'All app cache, downloads, and user data cleared successfully.',
        ),
      );
      await fetchUserProfile();
    } catch (e) {
      emit(ProfileError('Failed to clear cache: ${e.toString()}'));
    }
  }

  Future<void> deleteAccount({String? password, bool useGoogle = false}) async {
    emit(ProfileUpdating());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const ProfileError('No authenticated user found.'));
        return;
      }

      // 1. Handle Re-authentication based on user's selected choice
      if (useGoogle) {
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            emit(const ProfileError('Google re-authentication was cancelled.'));
            return;
          }
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          emit(
            ProfileError(
              e.message ??
                  'Google re-authentication failed. Please try again.',
            ),
          );
          return;
        } catch (e) {
          emit(
            ProfileError('Google re-authentication failed: ${e.toString()}'),
          );
          return;
        }
      } else if (password != null && password.isNotEmpty) {
        if (user.email == null || user.email!.isEmpty) {
          emit(const ProfileError('No email associated with this account.'));
          return;
        }
        try {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            emit(
              const ProfileError(
                'Incorrect password. Account deletion cancelled.',
              ),
            );
          } else {
            emit(
              ProfileError(
                e.message ?? 'Password re-authentication failed.',
              ),
            );
          }
          return;
        } catch (e) {
          emit(ProfileError('Re-authentication failed: ${e.toString()}'));
          return;
        }
      }

      final uid = user.uid;

      // 2. Delete Firestore user document
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (_) {}

      // 3. Clear all local storage (RAM image cache, temp files, app documents, SharedPreferences)
      try {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      } catch (_) {}

      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          final tempFiles = tempDir.listSync();
          for (final entity in tempFiles) {
            try {
              if (entity is File) {
                await entity.delete();
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
              }
            } catch (_) {}
          }
        }
      } catch (_) {}

      try {
        final appDir = await getApplicationDocumentsDirectory();
        if (await appDir.exists()) {
          final appEntities = appDir.listSync();
          for (final entity in appEntities) {
            try {
              if (entity is File) {
                await entity.delete();
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
              }
            } catch (_) {}
          }
        }
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 4. Delete Firebase Auth user and sign out Google session
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      await user.delete();

      emit(AccountDeletedSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(
          const ReauthRequired(
            'Security check: Account deletion requires recent authentication. Please log out and log back in, then try again.',
          ),
        );
      } else {
        emit(ProfileError(e.message ?? 'Failed to delete account.'));
      }
    } catch (e) {
      emit(ProfileError('Failed to delete account: ${e.toString()}'));
    }
  }
}
