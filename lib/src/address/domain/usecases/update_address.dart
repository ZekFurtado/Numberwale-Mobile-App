import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/domain/repositories/address_repository.dart';

/// This use case executes the business logic for updating an existing address.
/// The execution will move to the data layer by automatically calling
/// the method of the subclass of the dependency based on the dependency
/// injection defined in [lib/core/services/injection_container.dart]
class UpdateAddress extends UseCaseWithParams<Address, UpdateAddressParams> {
  /// Depends on the [AddressRepository] for its operations
  final AddressRepository repository;

  UpdateAddress(this.repository);

  @override
  ResultFuture<Address> call(UpdateAddressParams params) {
    return repository.updateAddress(
      addressId: params.addressId,
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

/// Parameters for updating an existing address
class UpdateAddressParams extends Equatable {
  final String addressId;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pinCode;
  final bool? isPrimary;

  const UpdateAddressParams({
    required this.addressId,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.city,
    this.state,
    this.pinCode,
    this.isPrimary,
  });

  @override
  List<Object?> get props => [
        addressId,
        addressLine1,
        addressLine2,
        landmark,
        city,
        state,
        pinCode,
        isPrimary,
      ];
}
