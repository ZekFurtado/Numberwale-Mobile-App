import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/authentication/data/datasources/auth_local_data_source.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/local_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// This implementation is called based on the dependency injection.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  ResultFuture<DataMap> register({
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
      await localDataSource.clearCache();
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
        accountType: accountType,
        getWhatsappUpdate: getWhatsappUpdate,
        acceptTermsAndConditions: acceptTermsAndConditions,
        companyName: companyName,
        gstinNo: gstinNo,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  ResultFuture<LocalUser> verifyOtp({
    String? email,
    String? mobile,
    required String otp,
  }) async {
    try {
      final user = await remoteDataSource.verifyOtp(
        email: email,
        mobile: mobile,
        otp: otp,
      );
      // Cache user data locally
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  ResultFuture<DataMap> resendOtp({
    String? email,
    String? mobile,
  }) async {
    try {
      final result = await remoteDataSource.resendOtp(
        email: email,
        mobile: mobile,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  ResultFuture<LocalUser> login({
    required String contact,
    required String password,
  }) async {
    try {
      // Drop any previous account's cached user + session cookies first, so
      // a stale jar can never survive into the new session (which would show
      // the previous account's cart/orders under the new login).
      await localDataSource.clearCache();
      final user = await remoteDataSource.login(
        contact: contact,
        password: password,
      );
      // Cache user data locally
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  ResultFuture<DataMap> signIn({
    required String mobile,
  }) async {
    try {
      await localDataSource.clearCache();
      final result = await remoteDataSource.signIn(mobile: mobile);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  ResultFuture<DataMap> forgotPassword({
    String? email,
    String? mobile,
  }) async {
    try {
      final result = await remoteDataSource.forgotPassword(
        email: email,
        mobile: mobile,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  ResultFuture<LocalUser> resetPassword({
    String? mobile,
    String? email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final user = await remoteDataSource.resetPassword(
        mobile: mobile,
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      // Cache user data locally
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  ResultVoid signOut() async {
    // Log out server-side *first* — that request needs the session cookies,
    // so clearing them beforehand would leave the session alive on the
    // backend. Local state is cleared either way.
    try {
      await remoteDataSource.signOut();
    } catch (_) {
      // Ignore server errors; the local session is cleared regardless.
    }
    await localDataSource.clearCache();
    return const Right(null);
  }

  @override
  ResultFuture<LocalUser> refreshToken() async {
    try {
      final user = await remoteDataSource.refreshToken();
      // Cache updated user data locally
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
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
  Future<LocalUser?> getCurrentUser() async {
    try {
      return await localDataSource.getCachedUser();
    } catch (_) {
      // A corrupted/unreadable cache just means there's nothing to restore
      // — not a reason to throw from a plain local read.
      return null;
    }
  }
}
