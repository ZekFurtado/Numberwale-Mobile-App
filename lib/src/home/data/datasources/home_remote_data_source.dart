import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/src/home/data/models/banner_model.dart';
import 'package:numberwale/src/home/data/models/category_model.dart';
import 'package:numberwale/src/home/data/models/phone_number_model.dart';

/// Abstract class defining all remote data operations for home screen
abstract class HomeRemoteDataSource {
  /// Fetches promotional banners from the API
  Future<List<BannerModel>> getBanners();

  /// Fetches categories from the API
  Future<List<CategoryModel>> getCategories();

  /// Fetches featured phone numbers from the API
  Future<List<PhoneNumberModel>> getFeaturedNumbers({int limit = 10});

  /// Fetches latest phone numbers from the API
  Future<List<PhoneNumberModel>> getLatestNumbers({int limit = 10});

  /// Fetches trending phone numbers from the API
  Future<List<PhoneNumberModel>> getTrendingNumbers({int limit = 10});
}

/// Implementation of HomeRemoteDataSource that makes actual API calls
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client _client;

  HomeRemoteDataSourceImpl(this._client);

  @override
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.bannersUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => BannerModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch banners',
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
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.categoriesUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => CategoryModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch categories',
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
  Future<List<PhoneNumberModel>> getFeaturedNumbers({int limit = 10}) async {
    try {
      final uri = Uri.parse(BackendConfig.featuredNumbersUrl)
          .replace(queryParameters: {'limit': limit.toString()});

      final response = await _client.get(
        uri,
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) =>
                PhoneNumberModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch featured numbers',
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
  Future<List<PhoneNumberModel>> getLatestNumbers({int limit = 10}) async {
    try {
      final uri = Uri.parse(BackendConfig.latestNumbersUrl)
          .replace(queryParameters: {'limit': limit.toString()});

      final response = await _client.get(
        uri,
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) =>
                PhoneNumberModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch latest numbers',
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
  Future<List<PhoneNumberModel>> getTrendingNumbers({int limit = 10}) async {
    try {
      final uri = Uri.parse(BackendConfig.trendingNumbersUrl)
          .replace(queryParameters: {'limit': limit.toString()});

      final response = await _client.get(
        uri,
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) =>
                PhoneNumberModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch trending numbers',
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
