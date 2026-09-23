import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/data/models/numerology_order_model.dart';

abstract class NumerologyRemoteDataSource {
  Future<NumerologyOrderModel> submitConsultation({
    required String firstName,
    required String lastName,
    required String day,
    required String month,
    required String year,
    required String mobile,
    required String email,
    required String serviceType,
    required String paymentGateway,
    String? purchaseNumber,
  });

  Future<String> verifyPayment({
    required String numerologyId,
    required String paymentId,
    required String paymentGateway,
  });
}

class NumerologyRemoteDataSourceImpl implements NumerologyRemoteDataSource {
  final http.Client _client;

  NumerologyRemoteDataSourceImpl(this._client);

  @override
  Future<NumerologyOrderModel> submitConsultation({
    required String firstName,
    required String lastName,
    required String day,
    required String month,
    required String year,
    required String mobile,
    required String email,
    required String serviceType,
    required String paymentGateway,
    String? purchaseNumber,
  }) async {
    try {
      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'day': day,
        'month': month,
        'year': year,
        'email': email,
        'mobile': mobile,
        'serviceType': serviceType,
        'paymentGateway': paymentGateway,
        'purchaseNumber': purchaseNumber ?? '',
      };

      log('Submitting numerology consultation ($serviceType) via $paymentGateway');

      final response = await _client.post(
        Uri.parse(BackendConfig.numerologyUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body) as DataMap;
      log('numerology submit status=${response.statusCode} body=${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: _errorMessage(responseData),
          statusCode: response.statusCode.toString(),
        );
      }

      // The backend also answers 200 with `success: false` when the profile
      // has no billing address (code ADDRESS_REQUIRED).
      if (responseData['success'] == false) {
        throw ServerException(
          message: _errorMessage(responseData),
          statusCode: '400',
        );
      }

      final data = responseData['data'] as DataMap? ?? responseData;
      return NumerologyOrderModel.fromMap(data);
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
  Future<String> verifyPayment({
    required String numerologyId,
    required String paymentId,
    required String paymentGateway,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.numerologyVerifyPaymentUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          'numerologyId': numerologyId,
          'paymentId': paymentId,
          'paymentGateway': paymentGateway,
        }),
      );

      final responseData = jsonDecode(response.body) as DataMap;
      log('numerology verify status=${response.statusCode} body=${response.body}');

      if (response.statusCode != 200 || responseData['success'] == false) {
        throw ServerException(
          message: _errorMessage(responseData, fallback: 'Payment verification failed'),
          statusCode: response.statusCode.toString(),
        );
      }

      return responseData['message'] as String? ??
          'Payment successful! Your numerology report is being prepared.';
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

  /// `ADDRESS_REQUIRED` is the one error worth rewording — the raw message
  /// doesn't tell the customer what to do about it.
  String _errorMessage(
    DataMap responseData, {
    String fallback = 'Failed to submit numerology request',
  }) {
    final data = responseData['data'];
    final code = data is DataMap ? data['code'] as String? : null;
    if (code == 'ADDRESS_REQUIRED') {
      return 'Please add a billing address to your profile before '
          'proceeding. This is required for generating your GST invoice.';
    }
    return responseData['message'] as String? ?? fallback;
  }
}
