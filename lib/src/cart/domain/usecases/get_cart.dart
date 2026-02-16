import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// This use case executes the business logic for fetching the current cart.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class GetCart extends UseCaseWithoutParams<Cart> {
  /// Depends on the [CartRepository] for its operations
  final CartRepository repository;

  GetCart(this.repository);

  @override
  ResultFuture<Cart> call() {
    return repository.getCart();
  }
}
