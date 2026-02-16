import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/data/models/cart_model.dart';
import 'package:numberwale/src/cart/data/models/checkout_result_model.dart';
import 'package:numberwale/src/cart/data/models/payment_gateway_model.dart';

/// Abstract class defining all remote data operations for the cart
abstract class CartRemoteDataSource {
  /// Fetches the current cart from the API
  Future<CartModel> getCart();

  /// Adds a product to the cart by product ID
  Future<CartModel> addToCart(String productId);

  /// Removes a specific item from the cart by item ID
  Future<void> removeCartItem(String itemId);

  /// Clears all items from the cart
  Future<void> clearCart();

  /// Validates the cart items via the API
  Future<CartModel> validateCart();

  /// Syncs local cart items with the server
  Future<CartModel> syncCart(List<DataMap> items);

  /// Initiates checkout with the given address and payment gateway
  Future<CheckoutResultModel> checkout(String addressId, String paymentGateway);

  /// Confirms a payment after successful gateway transaction
  Future<DataMap> confirmPayment(
      String paymentId, String orderId, String gateway);

  /// Fetches available payment gateways
  Future<List<PaymentGatewayModel>> getPaymentGateways();
}

/// Implementation of CartRemoteDataSource that makes actual API calls
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

      if (response.statusCode == 200) {
        final DataMap responseBody =
            jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CartModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch cart',
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
  Future<CartModel> addToCart(String productId) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.addToCartUrl(productId)),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final DataMap responseBody =
            jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CartModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to add item to cart',
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
  Future<CartModel> validateCart() async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.validateCartUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final DataMap responseBody =
            jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CartModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to validate cart',
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
  Future<CartModel> syncCart(List<DataMap> items) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.syncCartUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({'items': items}),
      );

      if (response.statusCode == 200) {
        final DataMap responseBody =
            jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CartModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to sync cart',
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
  Future<CheckoutResultModel> checkout(
      String addressId, String paymentGateway) async {
    try {
      final body = {
        'addressId': addressId,
        'paymentGateway': paymentGateway,
      };

      final response = await _client.post(
        Uri.parse(BackendConfig.checkoutUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final DataMap responseBody =
            jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        return CheckoutResultModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to initiate checkout',
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
  Future<DataMap> confirmPayment(
      String paymentId, String orderId, String gateway) async {
    try {
      final body = {
        'paymentId': paymentId,
        'orderId': orderId,
        'gateway': gateway,
      };

      final response = await _client.post(
        Uri.parse(BackendConfig.paymentSuccessUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as DataMap;
      } else {
        throw ServerException(
          message: 'Failed to confirm payment',
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
  Future<List<PaymentGatewayModel>> getPaymentGateways() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.paymentGatewaysUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final DataMap responseBody =
            jsonDecode(response.body) as DataMap;
        final data = responseBody['data'] as DataMap? ?? responseBody;
        final rawGateways = data['gateways'] as List<dynamic>? ??
            responseBody['data'] as List<dynamic>? ??
            [];
        return rawGateways
            .map((g) => PaymentGatewayModel.fromMap(g as DataMap))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch payment gateways',
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
