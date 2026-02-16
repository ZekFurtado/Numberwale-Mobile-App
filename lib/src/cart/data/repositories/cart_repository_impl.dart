import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/data/datasources/cart_remote_data_source.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_gateway.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// Implementation of CartRepository that handles data operations
/// and error handling. No local caching is used for cart operations.
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<Cart> getCart() async {
    try {
      final cart = await remoteDataSource.getCart();
      return Right(cart);
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
  ResultFuture<Cart> addToCart(String productId) async {
    try {
      final cart = await remoteDataSource.addToCart(productId);
      return Right(cart);
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
  ResultVoid removeCartItem(String itemId) async {
    try {
      await remoteDataSource.removeCartItem(itemId);
      return const Right(null);
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
  ResultVoid clearCart() async {
    try {
      await remoteDataSource.clearCart();
      return const Right(null);
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
  ResultFuture<Cart> validateCart() async {
    try {
      final cart = await remoteDataSource.validateCart();
      return Right(cart);
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
  ResultFuture<Cart> syncCart(List<DataMap> items) async {
    try {
      final cart = await remoteDataSource.syncCart(items);
      return Right(cart);
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
  ResultFuture<CheckoutResult> checkout(
      String addressId, String paymentGateway) async {
    try {
      final result =
          await remoteDataSource.checkout(addressId, paymentGateway);
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
  ResultFuture<DataMap> confirmPayment(
      String paymentId, String orderId, String gateway) async {
    try {
      final result =
          await remoteDataSource.confirmPayment(paymentId, orderId, gateway);
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
  ResultFuture<List<PaymentGateway>> getPaymentGateways() async {
    try {
      final gateways = await remoteDataSource.getPaymentGateways();
      return Right(gateways);
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
}
