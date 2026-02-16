import 'package:equatable/equatable.dart';

/// Represents the result of initiating a checkout
class CheckoutResult extends Equatable {
  /// Payment order ID from the payment gateway (e.g. razorpay order id)
  final String orderId;

  /// Human-readable order number (e.g. ORD-2026-001)
  final String orderNumber;

  /// Amount to be paid (in smallest currency unit, e.g. paise)
  final double amount;

  /// Currency code (e.g. INR)
  final String currency;

  /// Payment gateway identifier (e.g. razorpay, phonepe)
  final String gateway;

  /// Optional payment URL — used by PhonePe redirect flow
  final String? paymentUrl;

  const CheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.currency,
    required this.gateway,
    this.paymentUrl,
  });

  @override
  List<Object?> get props => [orderId, orderNumber];
}
