part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any orders have been requested
class OrderInitial extends OrderState {
  const OrderInitial();
}

/// Loading the first page of orders
class OrderLoading extends OrderState {
  const OrderLoading();
}

/// Loading more orders (pagination); carries the already-loaded orders
/// so the UI can continue to display them while fetching proceeds
class OrderLoadingMore extends OrderState {
  const OrderLoadingMore({required this.currentOrders});

  final List<Order> currentOrders;

  @override
  List<Object?> get props => [currentOrders];
}

/// Orders loaded successfully
class OrdersLoaded extends OrderState {
  const OrdersLoaded({
    required this.orders,
    required this.totalSpent,
    required this.hasNextPage,
    required this.currentPage,
    required this.totalPages,
  });

  final List<Order> orders;
  final double totalSpent;
  final bool hasNextPage;
  final int currentPage;
  final int totalPages;

  /// Returns a new [OrdersLoaded] with the provided [newOrders] appended
  /// to the current list — used to accumulate orders across pages.
  OrdersLoaded copyWithAdditionalOrders({
    required List<Order> newOrders,
    required double totalSpent,
    required bool hasNextPage,
    required int currentPage,
    required int totalPages,
  }) {
    return OrdersLoaded(
      orders: [...orders, ...newOrders],
      totalSpent: totalSpent,
      hasNextPage: hasNextPage,
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }

  @override
  List<Object?> get props => [orders, totalSpent, hasNextPage, currentPage, totalPages];
}

/// An error occurred while fetching orders
class OrderError extends OrderState {
  const OrderError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
