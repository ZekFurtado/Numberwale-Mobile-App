import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/orders/domain/entities/order.dart';
import 'package:numberwale/src/orders/domain/usecases/get_orders.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({required GetOrders getOrders})
      : _getOrders = getOrders,
        super(const OrderInitial()) {
    on<LoadOrdersEvent>(_loadOrdersHandler);
    on<LoadMoreOrdersEvent>(_loadMoreOrdersHandler);
  }

  final GetOrders _getOrders;

  Future<void> _loadOrdersHandler(
    LoadOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final result = await _getOrders(
      GetOrdersParams(page: event.page, limit: event.limit),
    );

    result.fold(
      (failure) {
        log('OrderBloc: LoadOrdersEvent failed — ${failure.message}');
        emit(OrderError(message: failure.message));
      },
      (ordersResult) => emit(
        OrdersLoaded(
          orders: _onlyPurchases(ordersResult.orders),
          totalSpent: ordersResult.totalSpent,
          hasNextPage: ordersResult.hasNextPage,
          currentPage: ordersResult.currentPage,
          totalPages: ordersResult.totalPages,
        ),
      ),
    );
  }

  /// Drops orders whose payment never completed.
  ///
  /// The backend creates an order as soon as checkout starts, so abandoning
  /// or failing a payment leaves an unpaid shell behind — which is why a
  /// brand new account that has bought nothing can still come back with rows
  /// here. Only actual purchases belong in "My Orders".
  List<Order> _onlyPurchases(List<Order> orders) {
    final purchases = orders.where((order) => order.isPaid).toList();
    final dropped = orders.length - purchases.length;
    if (dropped > 0) {
      log('OrderBloc: hiding $dropped unpaid order(s) from abandoned checkouts');
    }
    return purchases;
  }

  Future<void> _loadMoreOrdersHandler(
    LoadMoreOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded || !currentState.hasNextPage) return;

    emit(OrderLoadingMore(currentOrders: currentState.orders));

    final nextPage = currentState.currentPage + 1;

    final result = await _getOrders(
      GetOrdersParams(page: nextPage),
    );

    result.fold(
      (failure) {
        log('OrderBloc: LoadMoreOrdersEvent failed — ${failure.message}');
        emit(OrderError(message: failure.message));
      },
      (ordersResult) => emit(
        currentState.copyWithAdditionalOrders(
          newOrders: _onlyPurchases(ordersResult.orders),
          totalSpent: ordersResult.totalSpent,
          hasNextPage: ordersResult.hasNextPage,
          currentPage: ordersResult.currentPage,
          totalPages: ordersResult.totalPages,
        ),
      ),
    );
  }
}
