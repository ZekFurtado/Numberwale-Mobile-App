import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/data/datasources/cart_remote_data_source.dart';
import 'package:numberwale/src/cart/data/models/cart_item_model.dart';
import 'package:numberwale/src/cart/data/models/cart_model.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/repositories/cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The backend cart is localStorage-based (web). The server-side cart always
/// returns empty items. Mobile maintains a persisted local cart (SharedPreferences)
/// and syncs it to the server right before checkout.
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final SharedPreferences _prefs;

  static const String _cartKey = 'LOCAL_CART_ITEMS';

  CartRepositoryImpl(this.remoteDataSource, this._prefs) {
    _loadFromPrefs();
  }

  final List<CartItemModel> _localItems = [];

  void _loadFromPrefs() {
    try {
      final raw = _prefs.getString(_cartKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _localItems.addAll(
          list.map((e) => CartItemModel.fromMap(e as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      log('Failed to load cart from prefs: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final list = _localItems.map((i) => i.toMap()).toList();
      await _prefs.setString(_cartKey, jsonEncode(list));
    } catch (e) {
      log('Failed to save cart to prefs: $e');
    }
  }

  CartModel _buildLocalCart() {
    final subtotal = _localItems.fold<double>(
        0, (sum, item) => sum + item.price * item.quantity);
    const gstRate = 0.18;
    final taxAmount = subtotal * gstRate;
    final cgst = taxAmount / 2;
    final sgst = taxAmount / 2;
    final total = subtotal + taxAmount;

    return CartModel(
      items: _localItems,
      totalAmount: total,
      itemCount: _localItems.fold<int>(0, (s, i) => s + i.quantity),
      subtotal: subtotal,
      taxAmount: taxAmount,
      cgst: cgst,
      sgst: sgst,
    );
  }

  @override
  ResultFuture<Cart> getCart() async {
    return Right(_buildLocalCart());
  }

  @override
  ResultFuture<Cart> addToCart(String productId, String productNumber, double price) async {
    try {
      await remoteDataSource.addToCart(productId);

      final existingIndex = _localItems.indexWhere((i) => i.productId == productId);
      if (existingIndex >= 0) {
        final existing = _localItems[existingIndex];
        _localItems[existingIndex] = CartItemModel(
          id: existing.id,
          productId: existing.productId,
          productNumber: existing.productNumber,
          price: existing.price,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
        );
      } else {
        _localItems.add(CartItemModel(
          productId: productId,
          productNumber: productNumber,
          price: price,
          quantity: 1,
        ));
      }

      await _saveToPrefs();
      return Right(_buildLocalCart());
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
    _localItems.removeWhere((i) => i.id == itemId || i.productId == itemId);
    await _saveToPrefs();
    return const Right(null);
  }

  @override
  ResultVoid clearCart() async {
    _localItems.clear();
    await _saveToPrefs();
    return const Right(null);
  }

  @override
  ResultFuture<Cart> validateCart() async {
    try {
      final cart = await remoteDataSource.validateCart();
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
  ResultFuture<CheckoutResult> checkout(String addressId, String paymentGateway) async {
    try {
      if (_localItems.isNotEmpty) {
        try {
          final itemMaps = _localItems.map((i) => i.toMap()).toList();
          await remoteDataSource.syncCart(itemMaps);
        } catch (e) {
          log('syncCart failed (non-fatal): $e');
        }
      }

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
}
