import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/profile/data/models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(DataMap profileData);
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _client.get(
        Uri.parse(BackendConfig.getUserProfileUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        final userData = (data['data'] as DataMap)['user'] as DataMap;
        return UserProfileModel.fromMap(userData);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to fetch profile',
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
  Future<UserProfileModel> updateProfile(DataMap profileData) async {
    try {
      final response = await _client.put(
        Uri.parse(BackendConfig.updateProfileUrl),
        headers: BackendConfig.headers,
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        final userData = (data['data'] as DataMap)['user'] as DataMap;
        return UserProfileModel.fromMap(userData);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to update profile',
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
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse(BackendConfig.updatePasswordUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to update password',
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
