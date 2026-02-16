part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final UserProfile currentProfile;

  const ProfileUpdating({required this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class UpdatingPassword extends ProfileState {
  const UpdatingPassword();
}

class PasswordUpdated extends ProfileState {
  const PasswordUpdated();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
