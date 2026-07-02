import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';

class CheckoutResultModel extends CheckoutResult {
  const CheckoutResultModel({
    required super.orderId,
    required super.orderNumber,
    required super.amount,
    required super.currency,
    super.paymentUrl,
  });

  factory CheckoutResultModel.fromMap(DataMap map) {
    final data = map['data'] as DataMap? ?? map;

    final order = data['order'] as DataMap?;
    final orderNumber = order != null
        ? (order['orderNumber'] as String? ?? '')
        : (data['orderNumber'] as String? ?? '');

    // /cart/checkout's `amount` is in paise (it's Razorpay's/PhonePe's own
    // order amount, relayed as-is) — normalize to rupees here so the rest of
    // the app (Order Success display, etc.) can treat CheckoutResult.amount
    // like every other amount in the app. Confirmed against a real Razorpay
    // "amount/order_id mismatch" failure: the SDK needs paise, computed by
    // multiplying this (rupee) value back by 100 — see order_summary_page's
    // _openRazorpay.
    final rawAmount = (data['amount'] as num? ?? 0).toDouble();

    return CheckoutResultModel(
      orderId: data['orderId'] as String? ?? data['order_id'] as String? ?? '',
      orderNumber: orderNumber,
      amount: rawAmount / 100,
      currency: data['currency'] as String? ?? 'INR',
      paymentUrl: data['paymentUrl'] as String?,
    );
  }
}
