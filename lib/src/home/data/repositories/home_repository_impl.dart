import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/data/datasources/home_local_data_source.dart';
import 'package:numberwale/src/home/data/datasources/home_remote_data_source.dart';
import 'package:numberwale/src/home/domain/entities/banner.dart';
import 'package:numberwale/src/home/domain/entities/category.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/home/domain/repositories/home_repository.dart';

/// Implementation of HomeRepository that handles data operations
/// and error handling
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  ResultFuture<List<Banner>> getBanners() async {
    try {
      final banners = await remoteDataSource.getBanners();
      // Cache the banners locally for offline access
      await localDataSource.cacheBanners(banners);
      return Right(banners);
    } on ServerException catch (e) {
      // Try to get cached banners if network call fails
      try {
        final cachedBanners = await localDataSource.getCachedBanners();
        return Right(cachedBanners);
      } on CacheException {
        // If both network and cache fail, return the network error
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } on NetworkException {
      // Try to get cached banners if no network
      try {
        final cachedBanners = await localDataSource.getCachedBanners();
        return Right(cachedBanners);
      } on CacheException {
        return const Left(NetworkFailure(
          message: 'No internet connection and no cached data',
          statusCode: '503',
        ));
      }
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<List<Category>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      // Cache the categories locally for offline access
      await localDataSource.cacheCategories(categories);
      return Right(categories);
    } on ServerException catch (e) {
      // Try to get cached categories if network call fails
      try {
        final cachedCategories = await localDataSource.getCachedCategories();
        return Right(cachedCategories);
      } on CacheException {
        // If both network and cache fail, return the network error
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } on NetworkException {
      // Try to get cached categories if no network
      try {
        final cachedCategories = await localDataSource.getCachedCategories();
        return Right(cachedCategories);
      } on CacheException {
        return const Left(NetworkFailure(
          message: 'No internet connection and no cached data',
          statusCode: '503',
        ));
      }
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<List<PhoneNumber>> getDiscountedNumbers({int limit = 10}) async {
    try {
      final numbers =
          await remoteDataSource.getDiscountedNumbers(limit: limit);
      await localDataSource.cacheDiscountedNumbers(numbers);
      return Right(numbers);
    } on ServerException catch (e) {
      try {
        final cached = await localDataSource.getCachedDiscountedNumbers();
        return Right(cached);
      } on CacheException {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } on NetworkException {
      try {
        final cached = await localDataSource.getCachedDiscountedNumbers();
        return Right(cached);
      } on CacheException {
        return const Left(NetworkFailure(
          message: 'No internet connection and no cached data',
          statusCode: '503',
        ));
      }
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }
}
