import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';

abstract class ContactRemoteDataSource {
  Future<void> submitContact({
    required String name,
    required String email,
    required String mobileNo,
    required String message,
    String? companyName,
    String? type,
  });

  Future<void> submitCareerApplication({
    required String name,
    required String email,
    required String mobile,
    required String resume,
    String? coverLetter,
  });
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final http.Client _client;

  ContactRemoteDataSourceImpl(this._client);

  @override
  Future<void> submitContact({
    required String name,
    required String email,
    required String mobileNo,
    required String message,
    String? companyName,
    String? type,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'mobileNo': mobileNo,
        'message': message,
        'agreeToContact': true,
        if (companyName != null) 'cname': companyName,
        if (type != null) 'type': type,
      };

      log('Submitting contact form for $email');

      final response = await _client.post(
        Uri.parse(BackendConfig.contactUsUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          statusCode: response.statusCode.toString(),
          message: responseBody['message'] as String? ?? 'Failed to submit contact form',
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
      throw ServerException(statusCode: '500', message: e.toString());
    }
  }

  @override
  Future<void> submitCareerApplication({
    required String name,
    required String email,
    required String mobile,
    required String resume,
    String? coverLetter,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'mobile': mobile,
        'resume': resume,
        'agreeToContact': true,
        if (coverLetter != null) 'coverLetter': coverLetter,
      };

      log('Submitting career application for $email');

      final response = await _client.post(
        Uri.parse(BackendConfig.careerApplicationUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          statusCode: response.statusCode.toString(),
          message: responseBody['message'] as String? ?? 'Failed to submit career application',
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
      throw ServerException(statusCode: '500', message: e.toString());
    }
  }
}
