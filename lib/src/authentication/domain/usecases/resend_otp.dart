import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/domain/repositories/auth_repository.dart';

/// Use case for resending OTP
///
/// Resends OTP to user's email or mobile.
/// Used when OTP expires or user didn't receive it.
///
/// Returns a map containing:
/// - otpExpiry: DateTime when new OTP expires
/// - channels: Map of delivery channels (email, sms)
class ResendOtp extends UseCaseWithParams<DataMap, ResendOtpParams> {
  final AuthRepository _repository;

  ResendOtp(this._repository);

  @override
  ResultFuture<DataMap> call(ResendOtpParams params) {
    return _repository.resendOtp(
      email: params.email,
      mobile: params.mobile,
    );
  }
}

class ResendOtpParams extends Equatable {
  final String? email;
  final String? mobile;

  const ResendOtpParams({
    this.email,
    this.mobile,
  });

  @override
  List<Object?> get props => [email, mobile];
}
