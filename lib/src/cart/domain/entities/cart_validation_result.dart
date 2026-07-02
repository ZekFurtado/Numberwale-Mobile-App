import 'package:equatable/equatable.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';

/// Per-item result from POST /cart/validate.
class CartItemValidation extends Equatable {
  final String productId;
  final bool valid;
  final String message;

  const CartItemValidation({
    required this.productId,
    required this.valid,
    required this.message,
  });

  @override
  List<Object?> get props => [productId, valid, message];
}

/// Result of validating the cart before checkout: which items are still
/// purchasable, plus the server's authoritative cart (updated pricing).
class CartValidationResult extends Equatable {
  final List<CartItemValidation> itemResults;
  final Cart cart;

  const CartValidationResult({
    required this.itemResults,
    required this.cart,
  });

  bool get isValid => itemResults.every((r) => r.valid);

  List<CartItemValidation> get invalidItems =>
      itemResults.where((r) => !r.valid).toList();

  @override
  List<Object?> get props => [itemResults, cart];
}
