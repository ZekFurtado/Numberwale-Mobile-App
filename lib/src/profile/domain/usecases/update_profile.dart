import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/profile/domain/entities/user_profile.dart';
import 'package:numberwale/src/profile/domain/repositories/profile_repository.dart';

/// Use case to update the user's profile
class UpdateProfile extends UseCaseWithParams<UserProfile, UpdateProfileParams> {
  final ProfileRepository _repository;

  UpdateProfile(this._repository);

  @override
  ResultFuture<UserProfile> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      name: params.name,
      email: params.email,
      mobile: params.mobile,
      accountType: params.accountType,
      companyName: params.companyName,
      gstinNo: params.gstinNo,
      getWhatsappUpdate: params.getWhatsappUpdate,
      acceptTermsAndConditions: params.acceptTermsAndConditions,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String name;
  final String email;
  final String mobile;
  final String? accountType;
  final String? companyName;
  final String? gstinNo;
  final bool? getWhatsappUpdate;
  final bool? acceptTermsAndConditions;

  const UpdateProfileParams({
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
  List<Object?> get props => [name, email, mobile, accountType];
}
