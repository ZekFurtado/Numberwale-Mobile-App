import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/corporate_pack/data/models/corporate_pack_model.dart';

abstract class CorporatePackRemoteDataSource {
  Future<List<CorporatePackModel>> getCorporatePacks({
    required String matchType,
    required int packSize,
    int limit = 30,
  });
}

class CorporatePackRemoteDataSourceImpl implements CorporatePackRemoteDataSource {
  final http.Client _client;

  CorporatePackRemoteDataSourceImpl(this._client);

  @override
  Future<List<CorporatePackModel>> getCorporatePacks({
    required String matchType,
    required int packSize,
    int limit = 30,
  }) async {
    try {
      final uri = Uri.parse(BackendConfig.familyPacksWithProductsUrl)
          .replace(queryParameters: {
        'matchType': matchType,
        'packSize': packSize.toString(),
        'limit': limit.toString(),
      });

      final response = await _client.get(uri, headers: BackendConfig.headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // The API returns a raw JSON array of packs.
        final packsRaw = decoded is List
            ? decoded
            : (decoded as DataMap)['data'] as List<dynamic>? ?? [];
        return packsRaw
            .map((p) => CorporatePackModel.fromMap(p as DataMap))
            .toList();
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ??
              'Failed to fetch corporate elite packs',
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
