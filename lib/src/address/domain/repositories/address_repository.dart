import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/domain/entities/location_info.dart';

/// Contains all the methods specific for address management operations
abstract class AddressRepository {
  /// Automatically calls the respective class that implements this abstract
  /// class due to the dependency injection at runtime.
  ///
  /// In this case, since the dependencies are already set by the [sl] service
  /// locator, the respective subclass' method will be called.

  /// Fetches all addresses for the current user
  ResultFuture<List<Address>> getAddresses();

  /// Adds a new address for the current user
  ResultFuture<Address> addAddress({
    required String addressLine1,
    String? addressLine2,
    String? landmark,
    required String city,
    required String state,
    required String pinCode,
    bool isPrimary = false,
  });

  /// Updates an existing address
  ResultFuture<Address> updateAddress({
    required String addressId,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? pinCode,
    bool? isPrimary,
  });

  /// Deletes an address by ID
  ResultVoid deleteAddress({required String addressId});

  /// Sets an address as primary (and unsets other primary addresses)
  ResultVoid setPrimaryAddress({required String addressId});

  /// Gets city and state information from a PIN code
  ResultFuture<LocationInfo> getLocationFromPinCode({required String pinCode});
}
