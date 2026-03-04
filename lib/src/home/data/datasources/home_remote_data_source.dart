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
    // Endpoint removed - feature disabled
    throw const ServerException(
      message: 'Banners endpoint is not available',
      statusCode: '501',
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.getCategoriesUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check if response has a 'data' field (common API pattern)
        final dynamic data = jsonResponse['data'] ?? jsonResponse;

        if (data is List) {
          return data
              .map((json) => CategoryModel.fromMap(json as Map<String, dynamic>))
              .toList();
        } else {
          throw const ServerException(
            message: 'Invalid response format for categories',
            statusCode: '500',
          );
        }
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
    // Endpoint removed - feature disabled
    throw const ServerException(
      message: 'Featured numbers endpoint is not available',
      statusCode: '501',
    );
  }

  @override
  Future<List<PhoneNumberModel>> getLatestNumbers({int limit = 10}) async {
    // Endpoint removed - feature disabled
    throw const ServerException(
      message: 'Latest numbers endpoint is not available',
      statusCode: '501',
    );
  }

  @override
  Future<List<PhoneNumberModel>> getTrendingNumbers({int limit = 10}) async {
    // Endpoint removed - feature disabled
    throw const ServerException(
      message: 'Trending numbers endpoint is not available',
      statusCode: '501',
    );
  }
}
