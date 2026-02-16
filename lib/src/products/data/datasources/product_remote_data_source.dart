import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/products/data/models/product_model.dart';
import 'package:numberwale/src/products/data/models/product_result_model.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';

abstract class ProductRemoteDataSource {
  Future<ProductResultModel> getProducts(ProductFilters filters);
  Future<ProductResultModel> getDiscountedProducts(ProductFilters filters);
  Future<ProductModel> getProductByNumber(String number);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client _client;

  ProductRemoteDataSourceImpl(this._client);

  @override
  Future<ProductResultModel> getProducts(ProductFilters filters) async {
    try {
      final uri = Uri.parse(BackendConfig.getProductsUrl)
          .replace(queryParameters: filters.toQueryParams());

      final response = await _client.get(uri, headers: BackendConfig.headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        return ProductResultModel.fromMap(data);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to fetch products',
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
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<ProductResultModel> getDiscountedProducts(ProductFilters filters) async {
    try {
      final uri = Uri.parse(BackendConfig.getDiscountedProductsUrl)
          .replace(queryParameters: filters.toQueryParams());

      final response = await _client.get(uri, headers: BackendConfig.headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        return ProductResultModel.fromMap(data);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to fetch discounted products',
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
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<ProductModel> getProductByNumber(String number) async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.getProductByNumberUrl(number)),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        final productData = (data['data'] as DataMap)['product'] as DataMap;
        return ProductModel.fromMap(productData);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Product not found',
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
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }
}
