import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/data/datasources/cart_remote_data_source.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/cart_validation_result.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_confirmation_result.dart';
import 'package:numberwale/src/cart/domain/entities/phonepe_verification_result.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';

/// Thin pass-through to the server-side cart (see the Cart APIs in
/// NUMBERWALE_WEB_API_MASTER_DOCUMENTATION.md) — the server cart is always
/// the source of truth; nothing is cached or persisted locally.
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<Cart> getCart() async {
    try {
      final cart = await remoteDataSource.getCart();
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<Cart> addToCart(String productId) async {
    try {
      await remoteDataSource.addToCart(productId);
      // POST /cart/add/{productId} echoes items with a bare product id
      // string, not the populated product (number, pricing) — GET /cart
      // returns the fully populated cart, so re-fetch for a complete result.
      final cart = await remoteDataSource.getCart();
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultVoid removeCartItem(String itemId) async {
    try {
      await remoteDataSource.removeCartItem(itemId);
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
  ResultVoid clearCart() async {
    try {
      await remoteDataSource.clearCart();
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
  ResultFuture<CartValidationResult> validateCart() async {
    try {
      final result = await remoteDataSource.validateCart();
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
  ResultFuture<Cart> syncCart(List<DataMap> items) async {
    try {
      final cart = await remoteDataSource.syncCart(items);
      return Right(cart);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<CheckoutResult> checkout(
    String addressId,
    String paymentGateway,
  ) async {
    try {
      final result = await remoteDataSource.checkout(addressId, paymentGateway);
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
  ResultFuture<PhonePeVerificationResult> verifyPhonePePayment(
    String orderId,
  ) async {
    try {
      final result = await remoteDataSource.verifyPhonePePayment(orderId);
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
  ResultFuture<PaymentConfirmationResult> confirmPayment({
    required String paymentId,
    required String orderId,
    required String gateway,
  }) async {
    try {
      final result = await remoteDataSource.confirmPayment(
        paymentId: paymentId,
        orderId: orderId,
        gateway: gateway,
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
