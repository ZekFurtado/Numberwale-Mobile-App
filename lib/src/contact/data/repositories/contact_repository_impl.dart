import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/contact/data/datasources/contact_remote_data_source.dart';
import 'package:numberwale/src/contact/domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl(this.remoteDataSource);

  @override
  ResultVoid submitContact({
    required String name,
    required String email,
    required String mobileNo,
    required String message,
    String? companyName,
    String? type,
  }) async {
    try {
      await remoteDataSource.submitContact(
        name: name,
        email: email,
        mobileNo: mobileNo,
        message: message,
        companyName: companyName,
        type: type,
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

  @override
  ResultVoid submitCareerApplication({
    required String name,
    required String email,
    required String mobile,
    required String resume,
    String? coverLetter,
  }) async {
    try {
      await remoteDataSource.submitCareerApplication(
        name: name,
        email: email,
        mobile: mobile,
        resume: resume,
        coverLetter: coverLetter,
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
