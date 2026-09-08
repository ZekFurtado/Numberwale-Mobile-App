import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/ai_search/data/datasources/ai_search_remote_data_source.dart';
import 'package:numberwale/src/ai_search/domain/entities/ai_search_filters.dart';
import 'package:numberwale/src/ai_search/domain/repositories/ai_search_repository.dart';

class AiSearchRepositoryImpl implements AiSearchRepository {
  final AiSearchRemoteDataSource remoteDataSource;

  AiSearchRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<AiSearchFilters> search({
    required String query,
    Map<String, dynamic>? activeFilters,
  }) async {
    try {
      final result = await remoteDataSource.search(
        query: query,
        activeFilters: activeFilters,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
