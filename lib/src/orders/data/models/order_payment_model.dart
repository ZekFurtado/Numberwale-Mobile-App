import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/orders/domain/entities/order_payment.dart';

/// The model of the OrderPayment class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class OrderPaymentModel extends OrderPayment {
  const OrderPaymentModel({
    required super.amount,
    required super.method,
    required super.status,
  });

  /// Generates an empty OrderPaymentModel primarily for testing
  const OrderPaymentModel.empty()
      : this(
          amount: 0.0,
          method: 'empty.method',
          status: 'empty.status',
        );

  /// Creates an OrderPaymentModel from a Map
  factory OrderPaymentModel.fromMap(DataMap map) {
    return OrderPaymentModel(
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      method: map['method'] as String? ?? '',
      status: map['status'] as String? ?? '',
    );
  }

  /// Converts this OrderPaymentModel to a Map
  DataMap toMap() {
    return {
      'amount': amount,
      'method': method,
      'status': status,
    };
  }
}
