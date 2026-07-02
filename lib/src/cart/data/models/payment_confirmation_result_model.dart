import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/payment_confirmation_result.dart';

class PaymentConfirmationResultModel extends PaymentConfirmationResult {
  const PaymentConfirmationResultModel({
    required super.orderId,
    required super.orderNumber,
    required super.status,
  });

  /// [map] is the top-level decoded response body of
  /// POST /cart/payment-success: `{ status, message, data: { order: {...} } }`.
  factory PaymentConfirmationResultModel.fromMap(DataMap map) {
    final data = map['data'] as DataMap? ?? map;
    final order = data['order'] as DataMap? ?? data;

    return PaymentConfirmationResultModel(
      orderId: order['_id'] as String? ?? order['id'] as String? ?? '',
      orderNumber: order['orderNumber'] as String? ?? '',
      status: order['status'] as String? ?? 'processing',
    );
  }
}
