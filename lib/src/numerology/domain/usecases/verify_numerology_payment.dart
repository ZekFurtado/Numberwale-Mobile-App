import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/domain/repositories/numerology_repository.dart';

/// Confirms payment for a numerology request, which is what actually makes
/// the report available. Returns the server's confirmation message.
class VerifyNumerologyPayment
    extends UseCaseWithParams<String, VerifyNumerologyPaymentParams> {
  final NumerologyRepository _repository;

  VerifyNumerologyPayment(this._repository);

  @override
  ResultFuture<String> call(VerifyNumerologyPaymentParams params) {
    return _repository.verifyPayment(
      numerologyId: params.numerologyId,
      paymentId: params.paymentId,
      paymentGateway: params.paymentGateway,
    );
  }
}

class VerifyNumerologyPaymentParams extends Equatable {
  const VerifyNumerologyPaymentParams({
    required this.numerologyId,
    required this.paymentId,
    required this.paymentGateway,
  });

  final String numerologyId;
  final String paymentId;
  final String paymentGateway;

  @override
  List<Object?> get props => [numerologyId, paymentId, paymentGateway];
}
