import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/data/datasources/numerology_remote_data_source.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_order.dart';
import 'package:numberwale/src/numerology/domain/repositories/numerology_repository.dart';

class NumerologyRepositoryImpl implements NumerologyRepository {
  final NumerologyRemoteDataSource remoteDataSource;

  NumerologyRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<NumerologyOrder> submitConsultation({
    required String firstName,
    required String lastName,
    required String day,
    required String month,
    required String year,
    required String mobile,
    required String email,
    required String serviceType,
    required String paymentGateway,
    String? purchaseNumber,
  }) async {
    try {
      final order = await remoteDataSource.submitConsultation(
        firstName: firstName,
        lastName: lastName,
        day: day,
        month: month,
        year: year,
        mobile: mobile,
        email: email,
        serviceType: serviceType,
        paymentGateway: paymentGateway,
        purchaseNumber: purchaseNumber,
      );
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<String> verifyPayment({
    required String numerologyId,
    required String paymentId,
    required String paymentGateway,
  }) async {
    try {
      final message = await remoteDataSource.verifyPayment(
        numerologyId: numerologyId,
        paymentId: paymentId,
        paymentGateway: paymentGateway,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
