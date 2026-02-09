import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/entities/location_info.dart';
import 'package:numberwale/src/address/domain/repositories/address_repository.dart';

/// This use case executes the business logic for fetching location info
/// (city, state) from a PIN code. The execution will move to the data layer
/// by automatically calling the method of the subclass of the dependency based
/// on the dependency injection defined in [lib/core/services/injection_container.dart]
class GetLocationFromPinCode
    extends UseCaseWithParams<LocationInfo, GetLocationFromPinCodeParams> {
  /// Depends on the [AddressRepository] for its operations
  final AddressRepository repository;

  GetLocationFromPinCode(this.repository);

  @override
  ResultFuture<LocationInfo> call(GetLocationFromPinCodeParams params) {
    return repository.getLocationFromPinCode(pinCode: params.pinCode);
  }
}

/// Parameters for getting location info from PIN code
class GetLocationFromPinCodeParams extends Equatable {
  final String pinCode;

  const GetLocationFromPinCodeParams({required this.pinCode});

  @override
  List<Object?> get props => [pinCode];
}
