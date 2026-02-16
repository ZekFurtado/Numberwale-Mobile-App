import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/profile/domain/entities/user_profile.dart';
import 'package:numberwale/src/profile/domain/usecases/get_profile.dart';
import 'package:numberwale/src/profile/domain/usecases/update_password.dart';
import 'package:numberwale/src/profile/domain/usecases/update_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final UpdatePassword _updatePassword;

  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required UpdatePassword updatePassword,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _updatePassword = updatePassword,
        super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdatePasswordEvent>(_onUpdatePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await _getProfile();

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    UserProfile? currentProfile;
    if (currentState is ProfileLoaded) {
      currentProfile = currentState.profile;
    }

    emit(ProfileUpdating(
      currentProfile: currentProfile ?? const UserProfile.empty(),
    ));

    final result = await _updateProfile(UpdateProfileParams(
      name: event.name,
      email: event.email,
      mobile: event.mobile,
      accountType: event.accountType,
      companyName: event.companyName,
      gstinNo: event.gstinNo,
      getWhatsappUpdate: event.getWhatsappUpdate,
      acceptTermsAndConditions: event.acceptTermsAndConditions,
    ));

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileUpdated(profile: profile)),
    );
  }

  Future<void> _onUpdatePassword(
    UpdatePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const UpdatingPassword());

    final result = await _updatePassword(UpdatePasswordParams(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    ));

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const PasswordUpdated()),
    );
  }
}
