import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/orders/data/datasources/order_remote_data_source.dart';
import 'package:numberwale/src/orders/domain/entities/orders_result.dart';
import 'package:numberwale/src/orders/domain/repositories/order_repository.dart';

/// Implementation of OrderRepository that handles data operations
/// and error handling. No local caching is used for orders.
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<OrdersResult> getOrders({
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDataSource.getOrders(
        page: page,
        limit: limit,
      );
      return Right(result);
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
