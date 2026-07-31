abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? localPhotoPath;

  const ProfileLoaded({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.localPhotoPath,
  });
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);
}

class CacheClearedSuccess extends ProfileState {
  final String message;
  const CacheClearedSuccess(this.message);
}

class AccountDeletedSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

class ReauthRequired extends ProfileState {
  final String message;
  const ReauthRequired(this.message);
}
