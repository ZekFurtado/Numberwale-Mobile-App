import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/wishlist/data/models/wishlist_item_model.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItemModel>> getWishlist();

  Future<void> addToWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  });

  Future<void> removeFromWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  });
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final http.Client _client;

  WishlistRemoteDataSourceImpl(this._client);

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.wishlistUrl),
        headers: BackendConfig.headers,
      );

      log('getWishlist status=${response.statusCode}');

      if (response.statusCode != 200) {
        throw ServerException(
          message: _message(response.body, 'Failed to load your wishlist'),
          statusCode: response.statusCode.toString(),
        );
      }

      final body = jsonDecode(response.body) as DataMap;
      final rows = body['data'] as List<dynamic>? ?? const [];
      return rows
          .map((row) => WishlistItemModel.fromMap(row as DataMap))
          .whereType<WishlistItemModel>()
          .toList();
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
  Future<void> addToWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  }) async {
    try {
      final body = type == WishlistItemType.pack
          ? {
              'packId': itemId,
              'itemType': type.apiValue,
              'packSize': ?packSize,
            }
          : {'numberId': itemId, 'itemType': type.apiValue};

      final response = await _client.post(
        Uri.parse(BackendConfig.addToWishlistUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      log('addToWishlist status=${response.statusCode} body=${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: _message(response.body, 'Failed to save to your wishlist'),
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
  Future<void> removeFromWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  }) async {
    try {
      final uri = Uri.parse(BackendConfig.removeFromWishlistUrl(itemId))
          .replace(queryParameters: {
        'itemType': type.apiValue,
        // Packs are keyed by id *and* size, so the size must go along.
        'packSize': ?packSize?.toString(),
      });

      final response = await _client.delete(
        uri,
        headers: BackendConfig.headers,
      );

      log('removeFromWishlist status=${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: _message(
            response.body,
            'Failed to remove from your wishlist',
          ),
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

  String _message(String body, String fallback) {
    try {
      return (jsonDecode(body) as DataMap)['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
