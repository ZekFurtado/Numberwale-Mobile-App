import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_order.dart';

class NumerologyPaymentOrderModel extends NumerologyPaymentOrder {
  const NumerologyPaymentOrderModel({
    super.orderId,
    super.amount,
    super.currency,
    super.paymentUrl,
    super.merchantTransactionId,
  });

  factory NumerologyPaymentOrderModel.fromMap(DataMap map) {
    return NumerologyPaymentOrderModel(
      orderId: map['orderId'] as String? ??
          map['id'] as String? ??
          map['razorpayOrderId'] as String?,
      // Razorpay orders come back in paise, which is exactly what the
      // checkout SDK wants — pass it through untouched.
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      currency: map['currency'] as String? ?? 'INR',
      paymentUrl: map['paymentUrl'] as String?,
      merchantTransactionId: map['merchantTransactionId'] as String?,
    );
  }
}

class NumerologyOrderModel extends NumerologyOrder {
  const NumerologyOrderModel({
    required super.id,
    required super.paymentOrder,
  });

  /// Parses the `data` object of `POST /api/v1/numerology`:
  /// `{ id, paymentOrder: {...}, reportData: {...} }`.
  factory NumerologyOrderModel.fromMap(DataMap map) {
    final rawOrder = map['paymentOrder'] as DataMap? ?? const {};
    return NumerologyOrderModel(
      id: map['id'] as String? ?? map['_id'] as String? ?? '',
      paymentOrder: NumerologyPaymentOrderModel.fromMap(rawOrder),
    );
  }
}
