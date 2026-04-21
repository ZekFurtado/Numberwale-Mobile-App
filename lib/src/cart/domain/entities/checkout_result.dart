import 'package:equatable/equatable.dart';

/// Represents the result of initiating a checkout
class CheckoutResult extends Equatable {
  /// Internal order ID
  final String orderId;

  /// Human-readable order number (e.g. ORD-2026-001)
  final String orderNumber;

  /// Amount charged
  final double amount;

  /// Currency code (e.g. INR)
  final String currency;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.currency,
  });

  @override
  List<Object?> get props => [orderId, orderNumber];
}
