import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/orders/domain/entities/order_product.dart';

/// The model of the OrderProduct class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class OrderProductModel extends OrderProduct {
  const OrderProductModel({
    required super.productMobileNumber,
    required super.finalPrice,
    required super.status,
  });

  /// Generates an empty OrderProductModel primarily for testing
  const OrderProductModel.empty()
      : this(
          productMobileNumber: 'empty.productMobileNumber',
          finalPrice: 0.0,
          status: 'empty.status',
        );

  /// Creates an OrderProductModel from a Map
  factory OrderProductModel.fromMap(DataMap map) {
    return OrderProductModel(
      productMobileNumber: map['productMobileNumber'] as String? ?? '',
      finalPrice: (map['finalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? '',
    );
  }

  /// Converts this OrderProductModel to a Map
  DataMap toMap() {
    return {
      'productMobileNumber': productMobileNumber,
      'finalPrice': finalPrice,
      'status': status,
    };
  }
}
