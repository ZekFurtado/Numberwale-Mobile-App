import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/entities/local_user.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for verifying OTP
///
/// Verifies the OTP sent to user's email or mobile during:
/// - Registration
/// - Login with mobile (sign-in)
///
/// Returns authenticated user data on success.
class VerifyOtp extends UseCaseWithParams<LocalUser, VerifyOtpParams> {
  final AuthRepository _repository;

  VerifyOtp(this._repository);

  @override
  ResultFuture<LocalUser> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      email: params.email,
      mobile: params.mobile,
      otp: params.otp,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String? email;
  final String? mobile;
  final String otp;

  const VerifyOtpParams({
    this.email,
    this.mobile,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, mobile, otp];
}
