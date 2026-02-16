import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/orders/domain/entities/orders_result.dart';

/// Contains all the methods specific to order management operations
abstract class OrderRepository {
  /// Automatically calls the respective class that implements this abstract
  /// class due to the dependency injection at runtime.
  ///
  /// In this case, since the dependencies are already set by the [sl] service
  /// locator, the respective subclass' method will be called.

  /// Fetches a paginated list of orders for the current user
  ResultFuture<OrdersResult> getOrders({required int page, required int limit});
}
