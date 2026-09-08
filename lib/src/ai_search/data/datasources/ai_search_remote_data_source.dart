import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/ai_search/data/models/ai_search_filters_model.dart';

abstract class AiSearchRemoteDataSource {
  Future<AiSearchFiltersModel> search({
    required String query,
    Map<String, dynamic>? activeFilters,
  });
}

class AiSearchRemoteDataSourceImpl implements AiSearchRemoteDataSource {
  final http.Client _client;

  AiSearchRemoteDataSourceImpl(this._client);

  @override
  Future<AiSearchFiltersModel> search({
    required String query,
    Map<String, dynamic>? activeFilters,
  }) async {
    try {
      final body = jsonEncode({
        'query': query,
        if (activeFilters != null && activeFilters.isNotEmpty)
          'activeFilters': activeFilters,
      });

      log('[AiSearchDS] POST ${BackendConfig.aiSearchUrl} body=$body');
      final response = await _client.post(
        Uri.parse(BackendConfig.aiSearchUrl),
        headers: BackendConfig.headers,
        body: body,
      );
      log(
        '[AiSearchDS] status=${response.statusCode} body=${response.body.substring(0, response.body.length.clamp(0, 300))}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        return AiSearchFiltersModel.fromMap(data);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'AI search failed',
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
