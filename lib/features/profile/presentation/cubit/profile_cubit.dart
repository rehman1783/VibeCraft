import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wall_zen/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final ImagePicker _imagePicker;

  ProfileCubit({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    ImagePicker? imagePicker,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
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
      String? localPhotoPath = prefs.getString('local_profile_photo_path_${user.uid}');
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

      emit(ProfileLoaded(
        uid: user.uid,
        displayName: displayName,
        email: email,
        photoUrl: user.photoURL,
        localPhotoPath: localPhotoPath,
      ));
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
      final fileName = 'avatar_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_profile_photo_path_${user.uid}', savedFile.path);

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

      emit(const CacheClearedSuccess(
        'All app cache, downloads, and user data cleared successfully.',
      ));
      await fetchUserProfile();
    } catch (e) {
      emit(ProfileError('Failed to clear cache: ${e.toString()}'));
    }
  }

  Future<void> deleteAccount() async {
    emit(ProfileUpdating());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const ProfileError('No authenticated user found.'));
        return;
      }

      final uid = user.uid;

      // 1. Delete Firestore doc
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (_) {}

      // 2. Remove local photo path
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_profile_photo_path_$uid');

      // 3. Delete Firebase Auth user
      await user.delete();

      emit(AccountDeletedSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(const ReauthRequired(
          'Security check: Account deletion requires recent authentication. Please log out and log back in, then try again.',
        ));
      } else {
        emit(ProfileError(e.message ?? 'Failed to delete account.'));
      }
    } catch (e) {
      emit(ProfileError('Failed to delete account: ${e.toString()}'));
    }
  }
}
