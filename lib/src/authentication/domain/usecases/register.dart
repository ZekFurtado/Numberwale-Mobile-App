import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for user registration
///
/// Registers a new user with email, mobile, and password.
/// Sends OTP to user's mobile/email for verification.
///
/// Returns a map containing:
/// - otpExpiry: DateTime when OTP expires
/// - channels: Map of delivery channels (email, sms)
class Register extends UseCaseWithParams<DataMap, RegisterParams> {
  final AuthRepository _repository;

  Register(this._repository);

  @override
  ResultFuture<DataMap> call(RegisterParams params) {
    return _repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      mobile: params.mobile,
      accountType: params.accountType,
      getWhatsappUpdate: params.getWhatsappUpdate,
      acceptTermsAndConditions: params.acceptTermsAndConditions,
      companyName: params.companyName,
      gstinNo: params.gstinNo,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String mobile;
  final String accountType;
  final bool getWhatsappUpdate;
  final bool acceptTermsAndConditions;
  final String? companyName;
  final String? gstinNo;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
    required this.accountType,
    this.getWhatsappUpdate = false,
    this.acceptTermsAndConditions = true,
    this.companyName,
    this.gstinNo,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        mobile,
        accountType,
        getWhatsappUpdate,
        acceptTermsAndConditions,
        companyName,
        gstinNo,
      ];
}
