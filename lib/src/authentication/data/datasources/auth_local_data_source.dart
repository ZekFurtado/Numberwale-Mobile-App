import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/local_user_model.dart';

abstract class AuthLocalDataSource {
  /// Cache user data in local storage
  Future<void> cacheUser(LocalUserModel user);

  /// Get cached user data
  Future<LocalUserModel?> getCachedUser();

  /// Check if user is signed in (returns cached user)
  Future<LocalUserModel?> checkUserSignedIn();

  /// Clear all cached user data
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _cachedUserKey = 'CACHED_USER';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(LocalUserModel user) async {
    try {
      final userJson = jsonEncode(user.toMap());
      await sharedPreferences.setString(_cachedUserKey, userJson);
    } on TypeError {
      throw const CacheException(
        statusCode: "501",
        message: "Failed to cache user data",
      );
    } on ArgumentError {
      throw const CacheException(
        statusCode: "501",
        message: "Failed to cache user data",
      );
    } on FileSystemException {
      throw const CacheException(
        statusCode: "502",
        message: "Failed to cache user data. Please check file permissions",
      );
    }
  }

  @override
  Future<LocalUserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(_cachedUserKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return LocalUserModel.fromMap(userMap);
      }
      return null;
    } on TypeError {
      throw const CacheException(
        statusCode: "501",
        message: "Failed to retrieve cached user data",
      );
    } on ArgumentError {
      throw const CacheException(
        statusCode: "501",
        message: "Failed to retrieve cached user data",
      );
    } on FileSystemException {
      throw const CacheException(
        statusCode: "502",
        message: "Failed to retrieve cached user data. Please check file permissions",
      );
    } on FormatException {
      throw const CacheException(
        statusCode: "501",
        message: "Invalid cached user data format",
      );
    }
  }

  @override
  Future<LocalUserModel?> checkUserSignedIn() async {
    return getCachedUser();
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedUserKey);
    } on TypeError {
      throw const CacheException(
        statusCode: "501",
        message: "Failed to clear cache",
      );
    } on ArgumentError {
      throw const CacheException(
        statusCode: "501",
        message: "Failed to clear cache",
      );
    } on FileSystemException {
      throw const CacheException(
        statusCode: "502",
        message: "Failed to clear cache. Please check file permissions",
      );
    }
  }
}
