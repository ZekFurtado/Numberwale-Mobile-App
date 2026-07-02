import 'package:equatable/equatable.dart';

class CheckoutResult extends Equatable {
  final String orderId;
  final String orderNumber;
  final double amount;
  final String currency;

  /// Present when paymentGateway='phonepe': the hosted PhonePe payment page
  /// to redirect the user to (there is no PhonePe SDK token from this
  /// backend — see POST /cart/checkout in the API docs).
  final String? paymentUrl;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.currency,
    this.paymentUrl,
  });

  @override
  List<Object?> get props => [orderId, orderNumber];
}
