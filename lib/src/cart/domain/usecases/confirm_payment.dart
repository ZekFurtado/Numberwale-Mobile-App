import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// This use case executes the business logic for confirming a payment
/// after a successful gateway transaction.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class ConfirmPayment
    extends UseCaseWithParams<DataMap, ConfirmPaymentParams> {
  /// Depends on the [CartRepository] for its operations
  final CartRepository repository;

  ConfirmPayment(this.repository);

  @override
  ResultFuture<DataMap> call(ConfirmPaymentParams params) {
    return repository.confirmPayment(
      params.paymentId,
      params.orderId,
      params.gateway,
    );
  }
}

/// Parameters for confirming a payment
class ConfirmPaymentParams extends Equatable {
  final String paymentId;
  final String orderId;
  final String gateway;

  const ConfirmPaymentParams({
    required this.paymentId,
    required this.orderId,
    required this.gateway,
  });

  @override
  List<Object?> get props => [paymentId, orderId, gateway];
}
