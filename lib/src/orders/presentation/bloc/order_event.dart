part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the first page of orders
class LoadOrdersEvent extends OrderEvent {
  const LoadOrdersEvent({this.page = 1, this.limit = 10});

  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}

/// Event to load the next page of orders (pagination)
class LoadMoreOrdersEvent extends OrderEvent {
  const LoadMoreOrdersEvent();
}
