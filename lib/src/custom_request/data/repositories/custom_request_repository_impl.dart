import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/custom_request/data/datasources/custom_request_remote_data_source.dart';
import 'package:numberwale/src/custom_request/domain/entities/custom_request.dart';
import 'package:numberwale/src/custom_request/domain/repositories/custom_request_repository.dart';

class CustomRequestRepositoryImpl implements CustomRequestRepository {
  final CustomRequestRemoteDataSource remoteDataSource;

  CustomRequestRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<CustomRequest> submitRequest({
    required String requested,
    required String category,
    String? userId,
    String? name,
    String? email,
    String? mobileNo,
    String? city,
    String? phoneword,
  }) async {
    try {
      final requestData = {
        'requested': requested,
        'category': category,
        if (userId != null) 'user': userId,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (mobileNo != null) 'mobileNo': mobileNo,
        if (city != null) 'city': city,
        if (phoneword != null) 'phoneword': phoneword,
      };
      final result = await remoteDataSource.submitRequest(requestData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultVoid verifyOtp({
    required String customizeNumberId,
    required String otp,
  }) async {
    try {
      await remoteDataSource.verifyOtp(
        customizeNumberId: customizeNumberId,
        otp: otp,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
