import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/entities/local_user.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for resetting password with OTP
///
/// Verifies OTP and resets user's password.
/// Requires OTP from ForgotPassword use case.
///
/// Returns authenticated user data on success.
class ResetPassword extends UseCaseWithParams<LocalUser, ResetPasswordParams> {
  final AuthRepository _repository;

  ResetPassword(this._repository);

  @override
  ResultFuture<LocalUser> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      mobile: params.mobile,
      email: params.email,
      otp: params.otp,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String? mobile;
  final String? email;
  final String otp;
  final String newPassword;

  const ResetPasswordParams({
    this.mobile,
    this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [mobile, email, otp, newPassword];
}
