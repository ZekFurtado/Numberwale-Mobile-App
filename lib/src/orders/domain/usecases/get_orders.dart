import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/orders/domain/entities/orders_result.dart';
import 'package:numberwale/src/orders/domain/repositories/order_repository.dart';

/// This use case executes the business logic for fetching a paginated list
/// of orders for the current user. The execution will move to the data layer
/// by automatically calling the method of the subclass of the dependency
/// based on the dependency injection defined in
/// [lib/core/services/injection_container.dart]
class GetOrders extends UseCaseWithParams<OrdersResult, GetOrdersParams> {
  /// Depends on the [OrderRepository] for its operations
  final OrderRepository repository;

  GetOrders(this.repository);

  @override
  ResultFuture<OrdersResult> call(GetOrdersParams params) {
    return repository.getOrders(page: params.page, limit: params.limit);
  }
}

/// Parameters for fetching orders
class GetOrdersParams extends Equatable {
  final int page;
  final int limit;

  const GetOrdersParams({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}
