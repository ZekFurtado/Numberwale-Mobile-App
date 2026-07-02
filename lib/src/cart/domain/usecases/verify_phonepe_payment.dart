import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/phonepe_verification_result.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

class VerifyPhonePePayment
    extends UseCaseWithParams<PhonePeVerificationResult, VerifyPhonePePaymentParams> {
  final CartRepository repository;

  VerifyPhonePePayment(this.repository);

  @override
  ResultFuture<PhonePeVerificationResult> call(
    VerifyPhonePePaymentParams params,
  ) {
    return repository.verifyPhonePePayment(params.orderId);
  }
}

class VerifyPhonePePaymentParams extends Equatable {
  final String orderId;

  const VerifyPhonePePaymentParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
