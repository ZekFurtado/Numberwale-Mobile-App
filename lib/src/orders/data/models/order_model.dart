import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/orders/data/models/order_payment_model.dart';
import 'package:numberwale/src/orders/data/models/order_product_model.dart';
import 'package:numberwale/src/orders/domain/entities/order.dart';

/// The model of the Order class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class OrderModel extends Order {
  const OrderModel({
    super.id,
    required super.orderNumber,
    required super.status,
    required super.products,
    super.payment,
    super.createdAt,
    super.addressId,
  });

  /// Generates an empty OrderModel primarily for testing
  OrderModel.empty()
      : this(
          id: 'empty.id',
          orderNumber: 'ORD-0000-000',
          status: 'empty.status',
          products: const [],
          payment: const OrderPaymentModel.empty(),
          createdAt: DateTime(2026),
          addressId: null,
        );

  /// Creates an OrderModel from a Map
  factory OrderModel.fromMap(DataMap map) {
    final rawProducts = map['products'] as List<dynamic>? ?? [];
    final products = rawProducts
        .map((e) => OrderProductModel.fromMap(e as Map<String, dynamic>))
        .toList();

    final rawPayment = map['payment'] as Map<String, dynamic>?;
    final payment =
        rawPayment != null ? OrderPaymentModel.fromMap(rawPayment) : null;

    return OrderModel(
      id: map['_id'] as String? ?? map['id'] as String?,
      orderNumber: map['orderNumber'] as String? ?? '',
      status: map['status'] as String? ?? '',
      products: products,
      payment: payment,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      addressId: map['addressId'] as String?,
    );
  }

  /// Converts this OrderModel to a Map
  DataMap toMap() {
    return {
      if (id != null) '_id': id,
      'orderNumber': orderNumber,
      'status': status,
      'products': products
          .map((p) => (p as OrderProductModel).toMap())
          .toList(),
      if (payment != null) 'payment': (payment as OrderPaymentModel).toMap(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (addressId != null) 'addressId': addressId,
    };
  }
}
