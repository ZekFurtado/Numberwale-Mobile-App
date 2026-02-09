part of 'address_bloc.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AddressInitial extends AddressState {
  const AddressInitial();
}

/// Loading addresses
class LoadingAddresses extends AddressState {
  const LoadingAddresses();
}

/// Addresses loaded successfully
class AddressesLoaded extends AddressState {
  const AddressesLoaded({required this.addresses});

  final List<Address> addresses;

  @override
  List<Object> get props => [addresses];
}

/// Adding a new address
class AddingAddress extends AddressState {
  const AddingAddress();
}

/// Address added successfully
class AddressAdded extends AddressState {
  const AddressAdded({required this.address});

  final Address address;

  @override
  List<Object> get props => [address];
}

/// Updating an address
class UpdatingAddress extends AddressState {
  const UpdatingAddress();
}

/// Address updated successfully
class AddressUpdated extends AddressState {
  const AddressUpdated({required this.address});

  final Address address;

  @override
  List<Object> get props => [address];
}

/// Deleting an address
class DeletingAddress extends AddressState {
  const DeletingAddress();
}

/// Address deleted successfully
class AddressDeleted extends AddressState {
  const AddressDeleted({required this.addressId});

  final String addressId;

  @override
  List<Object> get props => [addressId];
}

/// Setting primary address
class SettingPrimaryAddress extends AddressState {
  const SettingPrimaryAddress();
}

/// Primary address set successfully
class PrimaryAddressSet extends AddressState {
  const PrimaryAddressSet({required this.addressId});

  final String addressId;

  @override
  List<Object> get props => [addressId];
}

/// Loading location from PIN code
class LoadingLocation extends AddressState {
  const LoadingLocation();
}

/// Location loaded successfully
class LocationLoaded extends AddressState {
  const LocationLoaded({required this.locationInfo});

  final LocationInfo locationInfo;

  @override
  List<Object> get props => [locationInfo];
}

/// Error occurred
class AddressError extends AddressState {
  const AddressError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
