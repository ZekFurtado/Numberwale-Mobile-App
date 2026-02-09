part of 'address_bloc.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all addresses for the current user
class GetAddressesEvent extends AddressEvent {
  const GetAddressesEvent();
}

/// Event to add a new address
class AddAddressEvent extends AddressEvent {
  const AddAddressEvent({
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pinCode,
    this.isPrimary = false,
  });

  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String pinCode;
  final bool isPrimary;

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

/// Event to update an existing address
class UpdateAddressEvent extends AddressEvent {
  const UpdateAddressEvent({
    required this.addressId,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.city,
    this.state,
    this.pinCode,
    this.isPrimary,
  });

  final String addressId;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pinCode;
  final bool? isPrimary;

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

/// Event to delete an address
class DeleteAddressEvent extends AddressEvent {
  const DeleteAddressEvent({required this.addressId});

  final String addressId;

  @override
  List<Object> get props => [addressId];
}

/// Event to set an address as primary
class SetPrimaryAddressEvent extends AddressEvent {
  const SetPrimaryAddressEvent({required this.addressId});

  final String addressId;

  @override
  List<Object> get props => [addressId];
}

/// Event to get location info from PIN code
class GetLocationFromPinCodeEvent extends AddressEvent {
  const GetLocationFromPinCodeEvent({required this.pinCode});

  final String pinCode;

  @override
  List<Object> get props => [pinCode];
}
