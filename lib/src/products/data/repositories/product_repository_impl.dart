import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/data/datasources/product_remote_data_source.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<ProductResult> getProducts(ProductFilters filters) async {
    try {
      final result = await remoteDataSource.getProducts(filters);
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
  ResultFuture<ProductResult> getDiscountedProducts(ProductFilters filters) async {
    try {
      final result = await remoteDataSource.getDiscountedProducts(filters);
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
  ResultFuture<PhoneNumber> getProductByNumber(String number) async {
    try {
      final product = await remoteDataSource.getProductByNumber(number);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
