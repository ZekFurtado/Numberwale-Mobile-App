import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/corporate_pack/data/datasources/corporate_pack_remote_data_source.dart';
import 'package:numberwale/src/corporate_pack/domain/entities/corporate_pack.dart';
import 'package:numberwale/src/corporate_pack/domain/repositories/corporate_pack_repository.dart';

class CorporatePackRepositoryImpl implements CorporatePackRepository {
  final CorporatePackRemoteDataSource remoteDataSource;

  CorporatePackRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<CorporatePack>> getCorporatePacks({
    required String matchType,
    required int packSize,
    int limit = 30,
  }) async {
    try {
      final packs = await remoteDataSource.getCorporatePacks(
        matchType: matchType,
        packSize: packSize,
        limit: limit,
      );
      return Right(packs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
