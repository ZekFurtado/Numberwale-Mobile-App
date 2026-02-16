import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/data/datasources/numerology_remote_data_source.dart';
import 'package:numberwale/src/numerology/domain/repositories/numerology_repository.dart';

class NumerologyRepositoryImpl implements NumerologyRepository {
  final NumerologyRemoteDataSource remoteDataSource;

  NumerologyRepositoryImpl(this.remoteDataSource);

  @override
  ResultVoid submitConsultation({
    required String firstName,
    required String lastName,
    required String gender,
    required String day,
    required String month,
    required String year,
    required String hours,
    required String minutes,
    required String meridian,
    required String birthPlace,
    required String language,
    required String mobile,
    required String email,
    String? purchaseNumber,
  }) async {
    try {
      await remoteDataSource.submitConsultation(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        day: day,
        month: month,
        year: year,
        hours: hours,
        minutes: minutes,
        meridian: meridian,
        birthPlace: birthPlace,
        language: language,
        mobile: mobile,
        email: email,
        purchaseNumber: purchaseNumber,
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
