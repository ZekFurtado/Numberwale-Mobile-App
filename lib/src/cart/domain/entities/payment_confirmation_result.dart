import 'package:equatable/equatable.dart';

/// Result of POST /cart/payment-success — confirms a gateway payment
/// (e.g. Razorpay) and finalizes the order that /cart/checkout created.
class PaymentConfirmationResult extends Equatable {
  final String orderId;
  final String orderNumber;
  final String status;

  const PaymentConfirmationResult({
    required this.orderId,
    required this.orderNumber,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, orderNumber, status];
}
