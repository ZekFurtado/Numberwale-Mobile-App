import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/src/address/data/models/address_model.dart';
import 'package:numberwale/src/address/data/models/location_info_model.dart';

/// Abstract class defining all remote data operations for addresses
abstract class AddressRemoteDataSource {
  /// Fetches all addresses for the current user from the API
  Future<List<AddressModel>> getAddresses();

  /// Adds a new address via the API
  Future<AddressModel> addAddress({
    required String addressLine1,
    String? addressLine2,
    String? landmark,
    required String city,
    required String state,
    required String pinCode,
    bool isPrimary = false,
  });

  /// Updates an existing address via the API
  Future<AddressModel> updateAddress({
    required String addressId,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? pinCode,
    bool? isPrimary,
  });

  /// Deletes an address by ID via the API
  Future<void> deleteAddress({required String addressId});

  /// Sets an address as primary via the API
  Future<void> setPrimaryAddress({required String addressId});

  /// Gets location info (city, state) from a PIN code
  Future<LocationInfoModel> getLocationFromPinCode({required String pinCode});
}

/// Implementation of AddressRemoteDataSource that makes actual API calls
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final http.Client _client;

  AddressRemoteDataSourceImpl(this._client);

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.addressesUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['data'] as List<dynamic>?)
              ?? (decoded['addresses'] as List<dynamic>?)
              ?? [];
        } else {
          list = [];
        }
        return list
            .map((json) => AddressModel.fromMap(_normalise(json as Map<String, dynamic>)))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw ServerException(
          message: 'Failed to fetch addresses',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: '503',
        message: 'No internet connection',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  /// Normalises a raw address map from the API: converts `_id` → `id`.
  Map<String, dynamic> _normalise(Map<String, dynamic> map) {
    if (!map.containsKey('id') && map.containsKey('_id')) {
      return {...map, 'id': map['_id']};
    }
    return map;
  }

  @override
  Future<AddressModel> addAddress({
    required String addressLine1,
    String? addressLine2,
    String? landmark,
    required String city,
    required String state,
    required String pinCode,
    bool isPrimary = false,
  }) async {
    try {
      final body = {
        'addressLine1': addressLine1,
        if (addressLine2 != null) 'addressLine2': addressLine2,
        if (landmark != null) 'landmark': landmark,
        'city': city,
        'state': state,
        'pinCode': pinCode,
        'isPrimary': isPrimary,
      };

      final response = await _client.post(
        Uri.parse(BackendConfig.addressesUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = decoded['data'] as Map<String, dynamic>?
            ?? decoded['address'] as Map<String, dynamic>?
            ?? decoded;
        return AddressModel.fromMap(_normalise(raw));
      } else {
        throw ServerException(
          message: 'Failed to add address',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: '503',
        message: 'No internet connection',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<AddressModel> updateAddress({
    required String addressId,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? pinCode,
    bool? isPrimary,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (addressLine1 != null) body['addressLine1'] = addressLine1;
      if (addressLine2 != null) body['addressLine2'] = addressLine2;
      if (landmark != null) body['landmark'] = landmark;
      if (city != null) body['city'] = city;
      if (state != null) body['state'] = state;
      if (pinCode != null) body['pinCode'] = pinCode;
      if (isPrimary != null) body['isPrimary'] = isPrimary;

      final response = await _client.put(
        Uri.parse(BackendConfig.updateAddressUrl(addressId)),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = decoded['data'] as Map<String, dynamic>?
            ?? decoded['address'] as Map<String, dynamic>?
            ?? decoded;
        return AddressModel.fromMap(_normalise(raw));
      } else {
        throw ServerException(
          message: 'Failed to update address',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: '503',
        message: 'No internet connection',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> deleteAddress({required String addressId}) async {
    try {
      final response = await _client.delete(
        Uri.parse(BackendConfig.deleteAddressUrl(addressId)),
        headers: BackendConfig.headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to delete address',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: '503',
        message: 'No internet connection',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> setPrimaryAddress({required String addressId}) async {
    try {
      final response = await _client.put(
        Uri.parse(BackendConfig.updateAddressUrl(addressId)),
        headers: BackendConfig.headers,
        body: jsonEncode({'isPrimary': true}),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to set primary address',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: '503',
        message: 'No internet connection',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<LocationInfoModel> getLocationFromPinCode({
    required String pinCode,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.getPinCodeInfoUrl(pinCode)),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?
            ?? decoded['result'] as Map<String, dynamic>?
            ?? decoded;
        return LocationInfoModel.fromMap(data);
      } else if (response.statusCode == 404) {
        throw ServerException(
          message: 'Invalid PIN code or location not found',
          statusCode: '404',
        );
      } else {
        throw ServerException(
          message: 'Failed to fetch location info',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: '503',
        message: 'No internet connection',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }
}
