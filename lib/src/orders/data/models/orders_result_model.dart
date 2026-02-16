import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/orders/data/models/order_model.dart';
import 'package:numberwale/src/orders/domain/entities/orders_result.dart';

/// The model of the OrdersResult class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class OrdersResultModel extends OrdersResult {
  const OrdersResultModel({
    required super.orders,
    required super.totalSpent,
    required super.totalOrders,
    required super.totalPages,
    required super.currentPage,
    required super.hasNextPage,
    required super.hasPrevPage,
  });

  /// Generates an empty OrdersResultModel primarily for testing
  const OrdersResultModel.empty()
      : this(
          orders: const [],
          totalSpent: 0.0,
          totalOrders: 0,
          totalPages: 0,
          currentPage: 1,
          hasNextPage: false,
          hasPrevPage: false,
        );

  /// Creates an OrdersResultModel from a Map
  ///
  /// Expected top-level keys: "data" (list), "totalSpent" (num),
  /// "pagination" (map with totalOrders, totalPages, currentPage,
  /// hasNextPage, hasPrevPage)
  factory OrdersResultModel.fromMap(DataMap map) {
    final rawData = map['data'] as List<dynamic>? ?? [];
    final orders = rawData
        .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
        .toList();

    final pagination = map['pagination'] as Map<String, dynamic>? ?? {};

    return OrdersResultModel(
      orders: orders,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalOrders: pagination['totalOrders'] as int? ?? 0,
      totalPages: pagination['totalPages'] as int? ?? 0,
      currentPage: pagination['currentPage'] as int? ?? 1,
      hasNextPage: pagination['hasNextPage'] as bool? ?? false,
      hasPrevPage: pagination['hasPrevPage'] as bool? ?? false,
    );
  }

  /// Converts this OrdersResultModel to a Map
  DataMap toMap() {
    return {
      'data': orders.map((o) => (o as OrderModel).toMap()).toList(),
      'totalSpent': totalSpent,
      'pagination': {
        'totalOrders': totalOrders,
        'totalPages': totalPages,
        'currentPage': currentPage,
        'hasNextPage': hasNextPage,
        'hasPrevPage': hasPrevPage,
      },
    };
  }
}
