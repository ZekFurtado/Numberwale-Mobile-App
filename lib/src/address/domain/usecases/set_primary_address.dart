import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/repositories/address_repository.dart';

/// This use case executes the business logic for setting an address as primary.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class SetPrimaryAddress extends UseCaseWithParams<void, SetPrimaryAddressParams> {
  /// Depends on the [AddressRepository] for its operations
  final AddressRepository repository;

  SetPrimaryAddress(this.repository);

  @override
  ResultVoid call(SetPrimaryAddressParams params) {
    return repository.setPrimaryAddress(addressId: params.addressId);
  }
}

/// Parameters for setting an address as primary
class SetPrimaryAddressParams extends Equatable {
  final String addressId;

  const SetPrimaryAddressParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
