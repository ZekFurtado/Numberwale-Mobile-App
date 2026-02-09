import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for requesting password reset OTP
///
/// Sends OTP to user's email or mobile for password reset.
/// User must use ResetPassword use case with OTP to complete the process.
///
/// Returns a map containing:
/// - otpExpiry: DateTime when OTP expires
/// - channels: Map of delivery channels (email, sms)
class ForgotPassword
    extends UseCaseWithParams<DataMap, ForgotPasswordParams> {
  final AuthRepository _repository;

  ForgotPassword(this._repository);

  @override
  ResultFuture<DataMap> call(ForgotPasswordParams params) {
    return _repository.forgotPassword(
      email: params.email,
      mobile: params.mobile,
    );
  }
}

class ForgotPasswordParams extends Equatable {
  final String? email;
  final String? mobile;

  const ForgotPasswordParams({
    this.email,
    this.mobile,
  });

  @override
  List<Object?> get props => [email, mobile];
}
