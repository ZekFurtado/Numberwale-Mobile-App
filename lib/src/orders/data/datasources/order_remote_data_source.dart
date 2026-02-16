import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/src/orders/data/models/orders_result_model.dart';

/// Abstract class defining all remote data operations for orders
abstract class OrderRemoteDataSource {
  /// Fetches a paginated list of orders for the current user from the API
  Future<OrdersResultModel> getOrders({required int page, required int limit});
}

/// Implementation of OrderRemoteDataSource that makes actual API calls
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final http.Client _client;

  OrderRemoteDataSourceImpl(this._client);

  @override
  Future<OrdersResultModel> getOrders({
    required int page,
    required int limit,
  }) async {
    try {
      final uri = Uri.parse(BackendConfig.getOrdersUrl).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await _client.get(
        uri,
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return OrdersResultModel.fromMap(data);
      } else {
        throw ServerException(
          message: 'Failed to fetch orders',
          statusCode: response.statusCode.toString(),
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
        statusCode: '503',
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
