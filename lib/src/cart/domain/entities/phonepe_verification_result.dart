import 'package:equatable/equatable.dart';

enum PhonePePaymentStatus { completed, pending, failed }

/// Result of POST /cart/verify-phonepe-payment.
class PhonePeVerificationResult extends Equatable {
  final PhonePePaymentStatus status;
  final String message;
  final String? orderId;
  final String? orderNumber;

  const PhonePeVerificationResult({
    required this.status,
    required this.message,
    this.orderId,
    this.orderNumber,
  });

  @override
  List<Object?> get props => [status, message, orderId, orderNumber];
}
