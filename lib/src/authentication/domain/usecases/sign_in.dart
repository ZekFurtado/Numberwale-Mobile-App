import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for mobile OTP login (sign-in)
///
/// Requests OTP to be sent to user's mobile number for passwordless login.
/// User must verify OTP using VerifyOtp use case to complete authentication.
///
/// Returns a map containing:
/// - otpExpiry: DateTime when OTP expires
/// - channels: Map of delivery channels (email, sms)
class SignIn extends UseCaseWithParams<DataMap, SignInParams> {
  final AuthRepository _repository;

  SignIn(this._repository);

  @override
  ResultFuture<DataMap> call(SignInParams params) {
    return _repository.signIn(mobile: params.mobile);
  }
}

class SignInParams extends Equatable {
  final String mobile;

  const SignInParams({required this.mobile});

  @override
  List<Object?> get props => [mobile];
}
