import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/data/models/cart_model.dart';
import 'package:numberwale/src/cart/data/models/checkout_result_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();

  Future<DataMap> addToCart(String productId);

  Future<void> removeCartItem(String itemId);

  Future<void> clearCart();

  Future<CartModel> validateCart();

  Future<CartModel> syncCart(List<DataMap> items);

  Future<CheckoutResultModel> checkout(String addressId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client _client;

  CartRemoteDataSourceImpl(this._client);

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.getCartUrl),
        headers: BackendConfig.headers,
      );

      log('getCart status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200) {
        final DataMap responseBody = jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CartModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch cart',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(statusCode: '503', message: 'No internet connection');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<DataMap> addToCart(String productId) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.addToCartUrl(productId)),
        headers: BackendConfig.headers,
      );
      log('addToCart status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final DataMap responseBody = jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return data['product'] as DataMap? ?? data;
      } else {
        throw ServerException(
          message: 'Failed to add item to cart',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(statusCode: '503', message: 'No internet connection');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<void> removeCartItem(String itemId) async {
    try {
      final response = await _client.delete(
        Uri.parse(BackendConfig.removeCartItemUrl(itemId)),
        headers: BackendConfig.headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to remove cart item',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(statusCode: '503', message: 'No internet connection');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      final response = await _client.delete(
        Uri.parse(BackendConfig.clearCartUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to clear cart',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(statusCode: '503', message: 'No internet connection');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<CartModel> validateCart() async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.validateCartUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final DataMap responseBody = jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CartModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to validate cart',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(statusCode: '503', message: 'No internet connection');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<CartModel> syncCart(List<DataMap> items) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.syncCartUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({'items': items}),
      );

      if (response.statusCode == 200) {
        final DataMap responseBody = jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CartModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to sync cart',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(statusCode: '503', message: 'No internet connection');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<CheckoutResultModel> checkout(String addressId) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.checkoutUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({'addressId': addressId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final DataMap responseBody = jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CheckoutResultModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to initiate checkout',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(statusCode: '503', message: 'No internet connection');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }
}
