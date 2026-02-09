import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:numberwale/core/errors/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:numberwale/core/utils/backend_config.dart';
import 'package:numberwale/core/utils/typedef.dart';

import '../models/local_user_model.dart';

abstract class AuthRemoteDataSource {
  /// Register a new user with email, mobile, and password
  /// Sends OTP for verification
  Future<DataMap> register({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required String accountType,
    bool getWhatsappUpdate = false,
    bool acceptTermsAndConditions = true,
    String? companyName,
    String? gstinNo,
  });

  /// Verify OTP sent during registration or login
  Future<LocalUserModel> verifyOtp({
    String? email,
    String? mobile,
    required String otp,
  });

  /// Resend OTP to user's email or mobile
  Future<DataMap> resendOtp({
    String? email,
    String? mobile,
  });

  /// Login with email/mobile and password
  Future<LocalUserModel> login({
    required String contact,
    required String password,
  });

  /// Request OTP for mobile number login
  Future<DataMap> signIn({
    required String mobile,
  });

  /// Request password reset OTP
  Future<DataMap> forgotPassword({
    String? email,
    String? mobile,
  });

  /// Reset password using OTP
  Future<LocalUserModel> resetPassword({
    String? mobile,
    String? email,
    required String otp,
    required String newPassword,
  });

  /// Sign out the user and invalidate tokens
  Future<void> signOut();

  /// Refresh authentication tokens
  Future<LocalUserModel> refreshToken();
}

/// This class deals with the authentication related remote API sources
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<DataMap> register({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required String accountType,
    bool getWhatsappUpdate = false,
    bool acceptTermsAndConditions = true,
    String? companyName,
    String? gstinNo,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.registerUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'mobile': mobile,
          'accountType': accountType,
          'getWhatsappUpdate': getWhatsappUpdate,
          'acceptTermsAndConditions': acceptTermsAndConditions,
          if (companyName != null) 'companyName': companyName,
          if (gstinNo != null) 'gstinNo': gstinNo,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as DataMap;
        return {
          'otpExpiry': data['otpExpiry'],
          'channels': data['channels'],
        };
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Registration failed',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<LocalUserModel> verifyOtp({
    String? email,
    String? mobile,
    required String otp,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.verifyOtpUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          if (email != null) 'email': email,
          if (mobile != null) 'mobile': mobile,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        final userData = data['data']['user'] as DataMap;
        return LocalUserModel.fromMap(userData);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'OTP verification failed',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<DataMap> resendOtp({
    String? email,
    String? mobile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.resendOtpUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          if (email != null) 'email': email,
          if (mobile != null) 'mobile': mobile,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        return {
          'otpExpiry': data['otpExpiry'],
          'channels': data['channels'],
        };
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to resend OTP',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<LocalUserModel> login({
    required String contact,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.loginUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          'contact': contact,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        final userData = data['data']['user'] as DataMap;
        return LocalUserModel.fromMap(userData);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Login failed',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<DataMap> signIn({
    required String mobile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.signInUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({'mobile': mobile}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        return {
          'otpExpiry': data['otpExpiry'],
          'channels': data['channels'],
        };
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Failed to send OTP',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<DataMap> forgotPassword({
    String? email,
    String? mobile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.forgotPasswordUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          if (email != null) 'email': email,
          if (mobile != null) 'mobile': mobile,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        return {
          'otpExpiry': data['otpExpiry'],
          'channels': data['channels'],
        };
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message:
              errorData['message'] as String? ?? 'Failed to send password reset OTP',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<LocalUserModel> resetPassword({
    String? mobile,
    String? email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.resetPasswordUrl),
        headers: BackendConfig.headers,
        body: jsonEncode({
          if (mobile != null) 'mobile': mobile,
          if (email != null) 'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        final userData = data['data']['user'] as DataMap;
        return LocalUserModel.fromMap(userData);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Password reset failed',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.logoutUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Logout failed',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<LocalUserModel> refreshToken() async {
    try {
      final response = await _client.post(
        Uri.parse(BackendConfig.refreshTokenUrl),
        headers: BackendConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as DataMap;
        final userData = data['data']['user'] as DataMap;
        return LocalUserModel.fromMap(userData);
      } else {
        final errorData = jsonDecode(response.body) as DataMap;
        throw ServerException(
          message: errorData['message'] as String? ?? 'Token refresh failed',
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
      throw ServerException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }
}
