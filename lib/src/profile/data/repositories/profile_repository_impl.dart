import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/profile/data/datasources/profile_remote_data_source.dart';
import 'package:numberwale/src/profile/domain/entities/user_profile.dart';
import 'package:numberwale/src/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<UserProfile> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<UserProfile> updateProfile({
    required String name,
    required String email,
    required String mobile,
    String? accountType,
    String? companyName,
    String? gstinNo,
    bool? getWhatsappUpdate,
    bool? acceptTermsAndConditions,
  }) async {
    try {
      final profileData = {
        'name': name,
        'email': email,
        'mobile': mobile,
        if (accountType != null) 'accountType': accountType,
        if (companyName != null) 'companyName': companyName,
        if (gstinNo != null) 'gstinNo': gstinNo,
        if (getWhatsappUpdate != null) 'getWhatsappUpdate': getWhatsappUpdate,
        if (acceptTermsAndConditions != null)
          'acceptTermsAndConditions': acceptTermsAndConditions,
      };
      final profile = await remoteDataSource.updateProfile(profileData);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultVoid updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
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
