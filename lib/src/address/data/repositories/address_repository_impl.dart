import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/data/datasources/address_local_data_source.dart';
import 'package:numberwale/src/address/data/datasources/address_remote_data_source.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/domain/entities/location_info.dart';
import 'package:numberwale/src/address/domain/repositories/address_repository.dart';

/// Implementation of AddressRepository that handles data operations
/// and error handling
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final AddressLocalDataSource localDataSource;

  AddressRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  ResultFuture<List<Address>> getAddresses() async {
    try {
      final addresses = await remoteDataSource.getAddresses();
      // Cache the addresses locally for offline access
      await localDataSource.cacheAddresses(addresses);
      return Right(addresses);
    } on ServerException catch (e) {
      // Try to get cached addresses if network call fails
      try {
        final cachedAddresses = await localDataSource.getCachedAddresses();
        return Right(cachedAddresses);
      } on CacheException {
        // If both network and cache fail, return the network error
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } on NetworkException {
      // Try to get cached addresses if no network
      try {
        final cachedAddresses = await localDataSource.getCachedAddresses();
        return Right(cachedAddresses);
      } on CacheException {
        return const Left(NetworkFailure(
          message: 'No internet connection and no cached addresses',
          statusCode: '503',
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<Address> addAddress({
    required String addressLine1,
    String? addressLine2,
    String? landmark,
    required String city,
    required String state,
    required String pinCode,
    bool isPrimary = false,
  }) async {
    try {
      final address = await remoteDataSource.addAddress(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        landmark: landmark,
        city: city,
        state: state,
        pinCode: pinCode,
        isPrimary: isPrimary,
      );
      // Clear cache to force refresh on next getAddresses call
      await localDataSource.clearCachedAddresses();
      return Right(address);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure(
        message: 'No internet connection. Please try again later.',
        statusCode: '503',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<Address> updateAddress({
    required String addressId,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? pinCode,
    bool? isPrimary,
  }) async {
    try {
      final address = await remoteDataSource.updateAddress(
        addressId: addressId,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        landmark: landmark,
        city: city,
        state: state,
        pinCode: pinCode,
        isPrimary: isPrimary,
      );
      // Clear cache to force refresh on next getAddresses call
      await localDataSource.clearCachedAddresses();
      return Right(address);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure(
        message: 'No internet connection. Please try again later.',
        statusCode: '503',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultVoid deleteAddress({required String addressId}) async {
    try {
      await remoteDataSource.deleteAddress(addressId: addressId);
      // Clear cache to force refresh on next getAddresses call
      await localDataSource.clearCachedAddresses();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure(
        message: 'No internet connection. Please try again later.',
        statusCode: '503',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultVoid setPrimaryAddress({required String addressId}) async {
    try {
      await remoteDataSource.setPrimaryAddress(addressId: addressId);
      // Clear cache to force refresh on next getAddresses call
      await localDataSource.clearCachedAddresses();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure(
        message: 'No internet connection. Please try again later.',
        statusCode: '503',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<LocationInfo> getLocationFromPinCode({
    required String pinCode,
  }) async {
    try {
      final locationInfo =
          await remoteDataSource.getLocationFromPinCode(pinCode: pinCode);
      return Right(locationInfo);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException {
      return const Left(NetworkFailure(
        message: 'No internet connection. Please try again later.',
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
