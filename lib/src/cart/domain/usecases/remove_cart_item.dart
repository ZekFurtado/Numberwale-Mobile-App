import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// This use case executes the business logic for removing an item from the cart.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class RemoveCartItem extends UseCaseWithParams<void, RemoveCartItemParams> {
  /// Depends on the [CartRepository] for its operations
  final CartRepository repository;

  RemoveCartItem(this.repository);

  @override
  ResultVoid call(RemoveCartItemParams params) {
    return repository.removeCartItem(params.itemId);
  }
}

/// Parameters for removing a cart item
class RemoveCartItemParams extends Equatable {
  final String itemId;

  const RemoveCartItemParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
