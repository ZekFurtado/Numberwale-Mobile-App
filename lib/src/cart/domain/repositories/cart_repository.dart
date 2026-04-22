import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';

abstract class CartRepository {
  ResultFuture<Cart> getCart();

  ResultFuture<Cart> addToCart(String productId, String productNumber, double price);

  ResultVoid removeCartItem(String itemId);

  ResultVoid clearCart();

  ResultFuture<Cart> validateCart();

  ResultFuture<Cart> syncCart(List<DataMap> items);

  ResultFuture<CheckoutResult> checkout(String addressId, String paymentGateway);
}
