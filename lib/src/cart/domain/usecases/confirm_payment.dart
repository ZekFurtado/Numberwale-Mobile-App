import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/payment_confirmation_result.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// Confirms a gateway payment (POST /cart/payment-success) — the step that
/// actually finalizes the order /cart/checkout created. Currently used for
/// Razorpay; PhonePe has its own dedicated verify-payment endpoint/flow.
class ConfirmPayment
    extends UseCaseWithParams<PaymentConfirmationResult, ConfirmPaymentParams> {
  final CartRepository repository;

  ConfirmPayment(this.repository);

  @override
  ResultFuture<PaymentConfirmationResult> call(ConfirmPaymentParams params) {
    return repository.confirmPayment(
      paymentId: params.paymentId,
      orderId: params.orderId,
      gateway: params.gateway,
    );
  }
}

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
