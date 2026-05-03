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

  /// Caches discounted numbers list locally
  Future<void> cacheDiscountedNumbers(List<PhoneNumberModel> numbers);

  /// Gets cached discounted numbers from local storage
  Future<List<PhoneNumberModel>> getCachedDiscountedNumbers();

  /// Clears all home screen cached data
  Future<void> clearCache();
}

/// Implementation of HomeLocalDataSource using SharedPreferences
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences _sharedPreferences;

  static const String _bannersCacheKey = 'CACHED_HOME_BANNERS';
  static const String _categoriesCacheKey = 'CACHED_HOME_CATEGORIES';
  static const String _discountedNumbersCacheKey = 'CACHED_DISCOUNTED_NUMBERS';

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
  Future<void> cacheDiscountedNumbers(List<PhoneNumberModel> numbers) async {
    try {
      final numbersJson = numbers.map((n) => n.toMap()).toList();
      await _sharedPreferences.setString(
        _discountedNumbersCacheKey,
        jsonEncode(numbersJson),
      );
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to cache discounted numbers: $e',
      );
    }
  }

  @override
  Future<List<PhoneNumberModel>> getCachedDiscountedNumbers() async {
    try {
      final cachedString =
          _sharedPreferences.getString(_discountedNumbersCacheKey);

      if (cachedString == null) {
        throw const CacheException(
          statusCode: '404',
          message: 'No cached discounted numbers found',
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
        message: 'Failed to get cached discounted numbers: $e',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Future.wait([
        _sharedPreferences.remove(_bannersCacheKey),
        _sharedPreferences.remove(_categoriesCacheKey),
        _sharedPreferences.remove(_discountedNumbersCacheKey),
      ]);
    } catch (e) {
      throw CacheException(
        statusCode: '500',
        message: 'Failed to clear home cache: $e',
      );
    }
  }
}
