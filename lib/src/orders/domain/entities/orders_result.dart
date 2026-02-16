import 'package:equatable/equatable.dart';
import 'package:numberwale/src/orders/domain/entities/order.dart';

/// Represents the paginated result returned when fetching orders
class OrdersResult extends Equatable {
  /// The list of orders for the current page
  final List<Order> orders;

  /// Total amount spent across all orders
  final double totalSpent;

  /// Total number of orders across all pages
  final int totalOrders;

  /// Total number of pages available
  final int totalPages;

  /// The current page number
  final int currentPage;

  /// Whether there is a next page available
  final bool hasNextPage;

  /// Whether there is a previous page available
  final bool hasPrevPage;

  const OrdersResult({
    required this.orders,
    required this.totalSpent,
    required this.totalOrders,
    required this.totalPages,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  @override
  List<Object?> get props => [orders, totalOrders, currentPage];
}
