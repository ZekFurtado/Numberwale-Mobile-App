import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/domain/repositories/address_repository.dart';

/// This use case executes the business logic for fetching all addresses
/// for the current user. The execution will move to the data layer by
/// automatically calling the method of the subclass of the dependency based
/// on the dependency injection defined in [lib/core/services/injection_container.dart]
class GetAddresses extends UseCaseWithoutParams<List<Address>> {
  /// Depends on the [AddressRepository] for its operations
  final AddressRepository repository;

  GetAddresses(this.repository);

  @override
  ResultFuture<List<Address>> call() {
    return repository.getAddresses();
  }
}
