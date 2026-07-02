import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';

abstract class NumerologyRemoteDataSource {
  /// Returns the success message from the server response.
  Future<String> submitConsultation({
    required String firstName,
    required String lastName,
    required String gender,
    required String day,
    required String month,
    required String year,
    required String hours,
    required String minutes,
    required String meridian,
    required String birthPlace,
    required String language,
    required String mobile,
    required String email,
    String? purchaseNumber,
  });
}

class NumerologyRemoteDataSourceImpl implements NumerologyRemoteDataSource {
  final http.Client _client;

  NumerologyRemoteDataSourceImpl(this._client);

  @override
  Future<String> submitConsultation({
    required String firstName,
    required String lastName,
    required String gender,
    required String day,
    required String month,
    required String year,
    required String hours,
    required String minutes,
    required String meridian,
    required String birthPlace,
    required String language,
    required String mobile,
    required String email,
    String? purchaseNumber,
  }) async {
    try {
      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'day': day,
        'month': month,
        'year': year,
        'hours': hours,
        'minutes': minutes,
        'meridian': meridian,
        'birthPlace': birthPlace,
        'language': language,
        'mobile': mobile,
        'email': email,
        if (purchaseNumber != null) 'purchaseNumber': purchaseNumber,
      };

      log('Submitting numerology consultation for $firstName $lastName');

      final response = await _client.post(
        Uri.parse(BackendConfig.numerologyUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: responseData['message'] as String? ??
              'Failed to submit numerology consultation',
          statusCode: response.statusCode.toString(),
        );
      }

      return responseData['message'] as String? ??
          'Numerology request submitted successfully! We will contact you within 24-48 hours.';
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
