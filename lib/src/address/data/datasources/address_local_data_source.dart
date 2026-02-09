import 'dart:convert';

import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/src/address/data/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract class defining all local data operations for addresses
abstract class AddressLocalDataSource {
  /// Caches addresses list locally
  Future<void> cacheAddresses(List<AddressModel> addresses);

  /// Gets cached addresses from local storage
  Future<List<AddressModel>> getCachedAddresses();

  /// Clears cached addresses from local storage
  Future<void> clearCachedAddresses();
}

/// Implementation of AddressLocalDataSource using SharedPreferences
class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  final SharedPreferences _sharedPreferences;

  static const String _addressesCacheKey = 'CACHED_ADDRESSES';

  AddressLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> cacheAddresses(List<AddressModel> addresses) async {
    try {
      final addressesJson =
          addresses.map((address) => address.toMap()).toList();
      await _sharedPreferences.setString(
        _addressesCacheKey,
        jsonEncode(addressesJson),
      );
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to cache addresses: $e',
      );
    }
  }

  @override
  Future<List<AddressModel>> getCachedAddresses() async {
    try {
      final cachedString = _sharedPreferences.getString(_addressesCacheKey);

      if (cachedString == null) {
        throw const CacheException(
          statusCode: '404',
          message: 'No cached addresses found',
        );
      }

      final List<dynamic> addressesJson = jsonDecode(cachedString) as List<dynamic>;
      return addressesJson
          .map((json) => AddressModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to get cached addresses: $e',
      );
    }
  }

  @override
  Future<void> clearCachedAddresses() async {
    try {
      await _sharedPreferences.remove(_addressesCacheKey);
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to clear cached addresses: $e',
      );
    }
  }
}
