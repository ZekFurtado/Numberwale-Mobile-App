import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/custom_request/data/models/custom_request_model.dart';

abstract class CustomRequestRemoteDataSource {
  Future<CustomRequestModel> submitRequest(DataMap requestData);
  Future<void> verifyOtp({
    required String customizeNumberId,
    required String otp,
  });
}

class CustomRequestRemoteDataSourceImpl
    implements CustomRequestRemoteDataSource {
  final http.Client _client;

  CustomRequestRemoteDataSourceImpl(this._client);

  @override
  Future<CustomRequestModel> submitRequest(DataMap requestData) async {
    try {
      log('CustomRequestRemoteDataSource: submitting request');
      final response = await _client.post(
        Uri.parse(BackendConfig.customizeNumberUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as DataMap;
        return CustomRequestModel.fromMap(data);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ??
              'Failed to submit custom number request',
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
  Future<void> verifyOtp({
    required String customizeNumberId,
    required String otp,
  }) async {
    try {
      log('CustomRequestRemoteDataSource: verifying OTP');
      final response = await _client.post(
        Uri.parse(BackendConfig.customizeNumberVerifyOtpUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          'customizeNumberId': customizeNumberId,
          'otp': otp,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to verify OTP',
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
