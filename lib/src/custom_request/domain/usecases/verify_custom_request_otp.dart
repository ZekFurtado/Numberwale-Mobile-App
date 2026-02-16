import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/custom_request/domain/repositories/custom_request_repository.dart';

class VerifyCustomRequestOtp
    extends UseCaseWithParams<void, VerifyCustomRequestOtpParams> {
  final CustomRequestRepository _repository;

  VerifyCustomRequestOtp(this._repository);

  @override
  ResultFuture<void> call(VerifyCustomRequestOtpParams params) {
    return _repository.verifyOtp(
      customizeNumberId: params.customizeNumberId,
      otp: params.otp,
    );
  }
}

class VerifyCustomRequestOtpParams extends Equatable {
  final String customizeNumberId;
  final String otp;

  const VerifyCustomRequestOtpParams({
    required this.customizeNumberId,
    required this.otp,
  });

  @override
  List<Object?> get props => [customizeNumberId, otp];
}
