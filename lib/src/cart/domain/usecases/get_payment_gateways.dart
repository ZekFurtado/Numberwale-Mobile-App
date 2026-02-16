import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/payment_gateway.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// This use case executes the business logic for fetching available payment gateways.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class GetPaymentGateways extends UseCaseWithoutParams<List<PaymentGateway>> {
  /// Depends on the [CartRepository] for its operations
  final CartRepository repository;

  GetPaymentGateways(this.repository);

  @override
  ResultFuture<List<PaymentGateway>> call() {
    return repository.getPaymentGateways();
  }
}
