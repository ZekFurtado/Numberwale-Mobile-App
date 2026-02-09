import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/domain/entities/location_info.dart';
import 'package:numberwale/src/address/domain/usecases/add_address.dart';
import 'package:numberwale/src/address/domain/usecases/delete_address.dart';
import 'package:numberwale/src/address/domain/usecases/get_addresses.dart';
import 'package:numberwale/src/address/domain/usecases/get_location_from_pincode.dart';
import 'package:numberwale/src/address/domain/usecases/set_primary_address.dart';
import 'package:numberwale/src/address/domain/usecases/update_address.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc({
    required GetAddresses getAddresses,
    required AddAddress addAddress,
    required UpdateAddress updateAddress,
    required DeleteAddress deleteAddress,
    required SetPrimaryAddress setPrimaryAddress,
    required GetLocationFromPinCode getLocationFromPinCode,
  })  : _getAddresses = getAddresses,
        _addAddress = addAddress,
        _updateAddress = updateAddress,
        _deleteAddress = deleteAddress,
        _setPrimaryAddress = setPrimaryAddress,
        _getLocationFromPinCode = getLocationFromPinCode,
        super(const AddressInitial()) {
    on<GetAddressesEvent>(_getAddressesHandler);
    on<AddAddressEvent>(_addAddressHandler);
    on<UpdateAddressEvent>(_updateAddressHandler);
    on<DeleteAddressEvent>(_deleteAddressHandler);
    on<SetPrimaryAddressEvent>(_setPrimaryAddressHandler);
    on<GetLocationFromPinCodeEvent>(_getLocationFromPinCodeHandler);
  }

  final GetAddresses _getAddresses;
  final AddAddress _addAddress;
  final UpdateAddress _updateAddress;
  final DeleteAddress _deleteAddress;
  final SetPrimaryAddress _setPrimaryAddress;
  final GetLocationFromPinCode _getLocationFromPinCode;

  Future<void> _getAddressesHandler(
    GetAddressesEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const LoadingAddresses());

    final result = await _getAddresses();

    result.fold(
      (failure) => emit(AddressError(message: failure.message)),
      (addresses) => emit(AddressesLoaded(addresses: addresses)),
    );
  }

  Future<void> _addAddressHandler(
    AddAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddingAddress());

    final result = await _addAddress(
      AddAddressParams(
        addressLine1: event.addressLine1,
        addressLine2: event.addressLine2,
        landmark: event.landmark,
        city: event.city,
        state: event.state,
        pinCode: event.pinCode,
        isPrimary: event.isPrimary,
      ),
    );

    result.fold(
      (failure) => emit(AddressError(message: failure.message)),
      (address) => emit(AddressAdded(address: address)),
    );
  }

  Future<void> _updateAddressHandler(
    UpdateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const UpdatingAddress());

    final result = await _updateAddress(
      UpdateAddressParams(
        addressId: event.addressId,
        addressLine1: event.addressLine1,
        addressLine2: event.addressLine2,
        landmark: event.landmark,
        city: event.city,
        state: event.state,
        pinCode: event.pinCode,
        isPrimary: event.isPrimary,
      ),
    );

    result.fold(
      (failure) => emit(AddressError(message: failure.message)),
      (address) => emit(AddressUpdated(address: address)),
    );
  }

  Future<void> _deleteAddressHandler(
    DeleteAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const DeletingAddress());

    final result = await _deleteAddress(
      DeleteAddressParams(addressId: event.addressId),
    );

    result.fold(
      (failure) => emit(AddressError(message: failure.message)),
      (_) => emit(AddressDeleted(addressId: event.addressId)),
    );
  }

  Future<void> _setPrimaryAddressHandler(
    SetPrimaryAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const SettingPrimaryAddress());

    final result = await _setPrimaryAddress(
      SetPrimaryAddressParams(addressId: event.addressId),
    );

    result.fold(
      (failure) => emit(AddressError(message: failure.message)),
      (_) => emit(PrimaryAddressSet(addressId: event.addressId)),
    );
  }

  Future<void> _getLocationFromPinCodeHandler(
    GetLocationFromPinCodeEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const LoadingLocation());

    final result = await _getLocationFromPinCode(
      GetLocationFromPinCodeParams(pinCode: event.pinCode),
    );

    result.fold(
      (failure) => emit(AddressError(message: failure.message)),
      (locationInfo) => emit(LocationLoaded(locationInfo: locationInfo)),
    );
  }
}
