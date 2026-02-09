import 'dart:convert';

import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/src/home/data/models/banner_model.dart';
import 'package:numberwale/src/home/data/models/category_model.dart';
import 'package:numberwale/src/home/data/models/phone_number_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract class defining all local data operations for home screen
abstract class HomeLocalDataSource {
  /// Caches banners list locally
  Future<void> cacheBanners(List<BannerModel> banners);

  /// Gets cached banners from local storage
  Future<List<BannerModel>> getCachedBanners();

  /// Caches categories list locally
  Future<void> cacheCategories(List<CategoryModel> categories);

  /// Gets cached categories from local storage
  Future<List<CategoryModel>> getCachedCategories();

  /// Caches featured numbers list locally
  Future<void> cacheFeaturedNumbers(List<PhoneNumberModel> numbers);

  /// Gets cached featured numbers from local storage
  Future<List<PhoneNumberModel>> getCachedFeaturedNumbers();

  /// Caches latest numbers list locally
  Future<void> cacheLatestNumbers(List<PhoneNumberModel> numbers);

  /// Gets cached latest numbers from local storage
  Future<List<PhoneNumberModel>> getCachedLatestNumbers();

  /// Clears all home screen cached data
  Future<void> clearCache();
}

/// Implementation of HomeLocalDataSource using SharedPreferences
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences _sharedPreferences;

  static const String _bannersCacheKey = 'CACHED_HOME_BANNERS';
  static const String _categoriesCacheKey = 'CACHED_HOME_CATEGORIES';
  static const String _featuredNumbersCacheKey = 'CACHED_FEATURED_NUMBERS';
  static const String _latestNumbersCacheKey = 'CACHED_LATEST_NUMBERS';

  HomeLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> cacheBanners(List<BannerModel> banners) async {
    try {
      final bannersJson = banners.map((banner) => banner.toMap()).toList();
      await _sharedPreferences.setString(
        _bannersCacheKey,
        jsonEncode(bannersJson),
      );
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to cache banners: $e',
      );
    }
  }

  @override
  Future<List<BannerModel>> getCachedBanners() async {
    try {
      final cachedString = _sharedPreferences.getString(_bannersCacheKey);

      if (cachedString == null) {
        throw const CacheException(
          statusCode: '404',
          message: 'No cached banners found',
        );
      }

      final List<dynamic> bannersJson =
          jsonDecode(cachedString) as List<dynamic>;
      return bannersJson
          .map((json) => BannerModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to get cached banners: $e',
      );
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    try {
      final categoriesJson =
          categories.map((category) => category.toMap()).toList();
      await _sharedPreferences.setString(
        _categoriesCacheKey,
        jsonEncode(categoriesJson),
      );
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to cache categories: $e',
      );
    }
  }

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    try {
      final cachedString = _sharedPreferences.getString(_categoriesCacheKey);

      if (cachedString == null) {
        throw const CacheException(
          statusCode: '404',
          message: 'No cached categories found',
        );
      }

      final List<dynamic> categoriesJson =
          jsonDecode(cachedString) as List<dynamic>;
      return categoriesJson
          .map((json) => CategoryModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to get cached categories: $e',
      );
    }
  }

  @override
  Future<void> cacheFeaturedNumbers(List<PhoneNumberModel> numbers) async {
    try {
      final numbersJson = numbers.map((number) => number.toMap()).toList();
      await _sharedPreferences.setString(
        _featuredNumbersCacheKey,
        jsonEncode(numbersJson),
      );
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to cache featured numbers: $e',
      );
    }
  }

  @override
  Future<List<PhoneNumberModel>> getCachedFeaturedNumbers() async {
    try {
      final cachedString =
          _sharedPreferences.getString(_featuredNumbersCacheKey);

      if (cachedString == null) {
        throw const CacheException(
          statusCode: '404',
          message: 'No cached featured numbers found',
        );
      }

      final List<dynamic> numbersJson =
          jsonDecode(cachedString) as List<dynamic>;
      return numbersJson
          .map((json) => PhoneNumberModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to get cached featured numbers: $e',
      );
    }
  }

  @override
  Future<void> cacheLatestNumbers(List<PhoneNumberModel> numbers) async {
    try {
      final numbersJson = numbers.map((number) => number.toMap()).toList();
      await _sharedPreferences.setString(
        _latestNumbersCacheKey,
        jsonEncode(numbersJson),
      );
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to cache latest numbers: $e',
      );
    }
  }

  @override
  Future<List<PhoneNumberModel>> getCachedLatestNumbers() async {
    try {
      final cachedString = _sharedPreferences.getString(_latestNumbersCacheKey);

      if (cachedString == null) {
        throw const CacheException(
          statusCode: '404',
          message: 'No cached latest numbers found',
        );
      }

      final List<dynamic> numbersJson =
          jsonDecode(cachedString) as List<dynamic>;
      return numbersJson
          .map((json) => PhoneNumberModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to get cached latest numbers: $e',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Future.wait([
        _sharedPreferences.remove(_bannersCacheKey),
        _sharedPreferences.remove(_categoriesCacheKey),
        _sharedPreferences.remove(_featuredNumbersCacheKey),
        _sharedPreferences.remove(_latestNumbersCacheKey),
      ]);
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to clear home cache: $e',
      );
    }
  }
}
