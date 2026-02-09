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
  ResultFuture<List<PhoneNumber>> getFeaturedNumbers({int limit = 10}) async {
    try {
      final numbers = await remoteDataSource.getFeaturedNumbers(limit: limit);
      // Cache the numbers locally for offline access
      await localDataSource.cacheFeaturedNumbers(numbers);
      return Right(numbers);
    } on ServerException catch (e) {
      // Try to get cached numbers if network call fails
      try {
        final cachedNumbers =
            await localDataSource.getCachedFeaturedNumbers();
        return Right(cachedNumbers);
      } on CacheException {
        // If both network and cache fail, return the network error
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } on NetworkException {
      // Try to get cached numbers if no network
      try {
        final cachedNumbers =
            await localDataSource.getCachedFeaturedNumbers();
        return Right(cachedNumbers);
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
  ResultFuture<List<PhoneNumber>> getLatestNumbers({int limit = 10}) async {
    try {
      final numbers = await remoteDataSource.getLatestNumbers(limit: limit);
      // Cache the numbers locally for offline access
      await localDataSource.cacheLatestNumbers(numbers);
      return Right(numbers);
    } on ServerException catch (e) {
      // Try to get cached numbers if network call fails
      try {
        final cachedNumbers = await localDataSource.getCachedLatestNumbers();
        return Right(cachedNumbers);
      } on CacheException {
        // If both network and cache fail, return the network error
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } on NetworkException {
      // Try to get cached numbers if no network
      try {
        final cachedNumbers = await localDataSource.getCachedLatestNumbers();
        return Right(cachedNumbers);
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
  ResultFuture<List<PhoneNumber>> getTrendingNumbers({int limit = 10}) async {
    try {
      final numbers = await remoteDataSource.getTrendingNumbers(limit: limit);
      return Right(numbers);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        statusCode: '503',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }
}
