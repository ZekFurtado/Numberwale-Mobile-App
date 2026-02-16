import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';

/// The model of the CheckoutResult class. This model extends the entity and
/// adds additional features to it (serialization/deserialization). This is
/// the model that will be used throughout the data layer.
class CheckoutResultModel extends CheckoutResult {
  const CheckoutResultModel({
    required super.orderId,
    required super.orderNumber,
    required super.amount,
    required super.currency,
    required super.gateway,
    super.paymentUrl,
  });

  /// Creates a CheckoutResultModel from a Map
  factory CheckoutResultModel.fromMap(DataMap map) {
    // The response may have nested data
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
      gateway: data['gateway'] as String? ?? '',
      paymentUrl: data['paymentUrl'] as String? ?? data['payment_url'] as String?,
    );
  }
}
