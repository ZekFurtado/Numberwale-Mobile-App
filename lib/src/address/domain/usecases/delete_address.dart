import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/repositories/address_repository.dart';

/// This use case executes the business logic for deleting an address.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class DeleteAddress extends UseCaseWithParams<void, DeleteAddressParams> {
  /// Depends on the [AddressRepository] for its operations
  final AddressRepository repository;

  DeleteAddress(this.repository);

  @override
  ResultVoid call(DeleteAddressParams params) {
    return repository.deleteAddress(addressId: params.addressId);
  }
}

/// Parameters for deleting an address
class DeleteAddressParams extends Equatable {
  final String addressId;

  const DeleteAddressParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
