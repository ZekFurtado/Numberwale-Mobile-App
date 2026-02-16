import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// This use case executes the business logic for adding a product to the cart.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class AddToCart extends UseCaseWithParams<Cart, AddToCartParams> {
  /// Depends on the [CartRepository] for its operations
  final CartRepository repository;

  AddToCart(this.repository);

  @override
  ResultFuture<Cart> call(AddToCartParams params) {
    return repository.addToCart(params.productId);
  }
}

/// Parameters for adding a product to the cart
class AddToCartParams extends Equatable {
  final String productId;

  const AddToCartParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}
