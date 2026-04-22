import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// This use case executes the business logic for initiating a checkout.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class Checkout extends UseCaseWithParams<CheckoutResult, CheckoutParams> {
  /// Depends on the [CartRepository] for its operations
  final CartRepository repository;

  Checkout(this.repository);

  @override
  ResultFuture<CheckoutResult> call(CheckoutParams params) {
    return repository.checkout(params.addressId, params.paymentGateway);
  }
}

/// Parameters for initiating a checkout
class CheckoutParams extends Equatable {
  final String addressId;
  final String paymentGateway;

  const CheckoutParams({
    required this.addressId,
    required this.paymentGateway,
  });

  @override
  List<Object?> get props => [addressId, paymentGateway];
}
