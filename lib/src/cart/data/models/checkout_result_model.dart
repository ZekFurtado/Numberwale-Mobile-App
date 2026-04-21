import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';

class CheckoutResultModel extends CheckoutResult {
  const CheckoutResultModel({
    required super.orderId,
    required super.orderNumber,
    required super.amount,
    required super.currency,
  });

  factory CheckoutResultModel.fromMap(DataMap map) {
    final data = map['data'] as DataMap? ?? map;

    final order = data['order'] as DataMap?;
    final orderNumber = order != null
        ? (order['orderNumber'] as String? ?? '')
        : (data['orderNumber'] as String? ?? '');

    return CheckoutResultModel(
      orderId: data['orderId'] as String? ?? data['order_id'] as String? ?? '',
      orderNumber: orderNumber,
      amount: (data['amount'] as num? ?? 0).toDouble(),
      currency: data['currency'] as String? ?? 'INR',
    );
  }
}
