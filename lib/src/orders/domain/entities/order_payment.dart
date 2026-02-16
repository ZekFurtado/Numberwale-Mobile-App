import 'package:equatable/equatable.dart';

/// Represents payment details attached to an order
class OrderPayment extends Equatable {
  /// Total amount charged for this payment
  final double amount;

  /// Payment method used (e.g. "razorpay", "phonepe")
  final String method;

  /// Payment status (e.g. "completed", "pending", "failed")
  final String status;

  const OrderPayment({
    required this.amount,
    required this.method,
    required this.status,
  });

  @override
  List<Object?> get props => [amount, method, status];
}
