import 'dart:convert';
import 'dart:developer';
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

  /// Fetches discounted phone numbers from the API
  Future<List<PhoneNumberModel>> getDiscountedNumbers({int limit = 10});
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
  Future<List<PhoneNumberModel>> getDiscountedNumbers({int limit = 10}) async {
    return _fetchProducts(
      url: BackendConfig.getDiscountedProductsUrl,
      queryParams: {'page': '1', 'limit': limit.toString()},
      label: 'discounted',
    );
  }

  Future<List<PhoneNumberModel>> _fetchProducts({
    required String url,
    required Map<String, String> queryParams,
    required String label,
  }) async {
    try {
      final uri =
          Uri.parse(url).replace(queryParameters: queryParams);
      log('[HomeDS] GET $label numbers: $uri');
      final response = await _client.get(uri, headers: BackendConfig.headers);
      log('[HomeDS] $label status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final productsRaw = data['products'] as List<dynamic>? ?? [];
        return productsRaw
            .map((p) => _parseProduct(p as Map<String, dynamic>))
            .toList();
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ServerException(
          message: errorData['message'] as String? ??
              'Failed to fetch $label numbers',
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

  /// Parses a product map from the products API into a [PhoneNumberModel].
  /// The products API uses a different field layout than the home API models
  /// (e.g. `productMobileNumber`, nested `pricing`, nested `category`).
  PhoneNumberModel _parseProduct(Map<String, dynamic> map) {
    final pricing = map['pricing'] as Map<String, dynamic>?;
    final finalPrice = pricing != null
        ? (pricing['nwFinalPrice'] as num?)?.toDouble() ?? 0.0
        : (map['price'] as num?)?.toDouble() ?? 0.0;
    final basePrice = pricing != null
        ? ((pricing['nwBasePrice'] as Map<String, dynamic>?)?['inr'] as num?)
            ?.toDouble()
        : null;
    final discountPct = pricing != null
        ? (pricing['nwMyDiscount'] as num?)?.toInt() ?? 0
        : (map['discount'] as num?)?.toInt() ?? 0;

    String categoryName = 'Unknown';
    String? categoryId;
    final categoryRaw = map['category'];
    if (categoryRaw is Map<String, dynamic>) {
      categoryName = categoryRaw['name'] as String? ?? 'Unknown';
      categoryId =
          categoryRaw['_id'] as String? ?? categoryRaw['id'] as String?;
    } else if (categoryRaw is String) {
      categoryName = categoryRaw;
    }

    final availability = map['availability'] as Map<String, dynamic>?;
    final isAvailable = availability != null
        ? (availability['status'] as String?) == 'available'
        : (map['isAvailable'] as bool? ?? true);

    final rtpValue = map['readyToPort'] as String?;

    return PhoneNumberModel(
      id: map['_id'] as String? ?? map['id'] as String?,
      number: map['productMobileNumber'] as String? ??
          map['number'] as String? ??
          '0000000000',
      price: finalPrice,
      originalPrice: basePrice,
      discount: discountPct,
      category: categoryName,
      categoryId: categoryId,
      operator: map['productBrand'] as String? ??
          map['operator'] as String? ??
          'Unknown',
      features: map['features'] != null
          ? List<String>.from(map['features'] as List<dynamic>)
          : [],
      numerology: map['numerology'] as Map<String, dynamic>?,
      isRTP: rtpValue == 'rtp',
      isCRTP: rtpValue == 'crtp',
      isFeatured: map['isFeatured'] as bool? ?? false,
      isTrending: map['isTrending'] as bool? ?? false,
      isAvailable: isAvailable,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}
