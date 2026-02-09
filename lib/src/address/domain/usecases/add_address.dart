import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/domain/repositories/address_repository.dart';

/// This use case executes the business logic for adding a new address.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class AddAddress extends UseCaseWithParams<Address, AddAddressParams> {
  /// Depends on the [AddressRepository] for its operations
  final AddressRepository repository;

  AddAddress(this.repository);

  @override
  ResultFuture<Address> call(AddAddressParams params) {
    return repository.addAddress(
      addressLine1: params.addressLine1,
      addressLine2: params.addressLine2,
      landmark: params.landmark,
      city: params.city,
      state: params.state,
      pinCode: params.pinCode,
      isPrimary: params.isPrimary,
    );
  }
}

/// Parameters for adding a new address
class AddAddressParams extends Equatable {
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String pinCode;
  final bool isPrimary;

  const AddAddressParams({
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pinCode,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [
        addressLine1,
        addressLine2,
        landmark,
        city,
        state,
        pinCode,
        isPrimary,
      ];
}
