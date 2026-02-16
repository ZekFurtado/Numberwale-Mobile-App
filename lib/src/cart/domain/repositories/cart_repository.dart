import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_gateway.dart';

/// Contains all the methods specific for cart management operations
abstract class CartRepository {
  /// Automatically calls the respective class that implements this abstract
  /// class due to the dependency injection at runtime.

  /// Fetches the current cart for the authenticated user
  ResultFuture<Cart> getCart();

  /// Adds a product to the cart by product ID
  ResultFuture<Cart> addToCart(String productId);

  /// Removes a specific item from the cart by item ID
  ResultVoid removeCartItem(String itemId);

  /// Clears all items from the cart
  ResultVoid clearCart();

  /// Validates the cart items (checks availability and pricing)
  ResultFuture<Cart> validateCart();

  /// Syncs local cart items with the server
  ResultFuture<Cart> syncCart(List<DataMap> items);

  /// Initiates checkout with the given address and payment gateway
  ResultFuture<CheckoutResult> checkout(String addressId, String paymentGateway);

  /// Confirms a payment after successful gateway transaction
  ResultFuture<DataMap> confirmPayment(
      String paymentId, String orderId, String gateway);

  /// Fetches available payment gateways
  ResultFuture<List<PaymentGateway>> getPaymentGateways();
}
