part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final String mobile;
  final String? accountType;
  final String? companyName;
  final String? gstinNo;
  final bool? getWhatsappUpdate;
  final bool? acceptTermsAndConditions;

  const UpdateProfileEvent({
    required this.name,
    required this.email,
    required this.mobile,
    this.accountType,
    this.companyName,
    this.gstinNo,
    this.getWhatsappUpdate,
    this.acceptTermsAndConditions,
  });

  @override
  List<Object?> get props => [name, email, mobile];
}

class UpdatePasswordEvent extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  const UpdatePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
