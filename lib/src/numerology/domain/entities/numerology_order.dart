import 'package:equatable/equatable.dart';

/// The payment order `POST /api/v1/numerology` creates alongside the
/// consultation request.
///
/// Razorpay orders carry [orderId]/[amount]/[currency]; PhonePe orders carry
/// [paymentUrl]/[merchantTransactionId] for a hosted-page redirect.
class NumerologyPaymentOrder extends Equatable {
  const NumerologyPaymentOrder({
    this.orderId,
    this.amount = 0,
    this.currency = 'INR',
    this.paymentUrl,
    this.merchantTransactionId,
  });

  final String? orderId;

  /// Amount in paise, as the Razorpay checkout SDK expects it.
  final int amount;
  final String currency;

  final String? paymentUrl;
  final String? merchantTransactionId;

  @override
  List<Object?> get props =>
      [orderId, amount, currency, paymentUrl, merchantTransactionId];
}

/// Result of submitting a numerology consultation: the created request's id
/// plus the payment order the customer now has to pay for.
class NumerologyOrder extends Equatable {
  const NumerologyOrder({
    required this.id,
    required this.paymentOrder,
  });

  /// The numerology request id — needed to verify payment and fetch the report.
  final String id;

  final NumerologyPaymentOrder paymentOrder;

  @override
  List<Object?> get props => [id, paymentOrder];
}
