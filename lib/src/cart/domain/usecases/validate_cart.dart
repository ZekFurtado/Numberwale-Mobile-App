import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/cart_validation_result.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// Validates the cart's items (availability, pricing) before checkout.
class ValidateCart extends UseCaseWithoutParams<CartValidationResult> {
  final CartRepository repository;

  ValidateCart(this.repository);

  @override
  ResultFuture<CartValidationResult> call() => repository.validateCart();
}
