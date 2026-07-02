import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/cart_validation_result.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_confirmation_result.dart';
import 'package:numberwale/src/cart/domain/entities/phonepe_verification_result.dart';

abstract class CartRepository {
  ResultFuture<Cart> getCart();

  ResultFuture<Cart> addToCart(String productId);

  ResultVoid removeCartItem(String itemId);

  ResultVoid clearCart();

  ResultFuture<CartValidationResult> validateCart();

  ResultFuture<Cart> syncCart(List<DataMap> items);

  ResultFuture<CheckoutResult> checkout(String addressId, String paymentGateway);

  ResultFuture<PhonePeVerificationResult> verifyPhonePePayment(String orderId);

  ResultFuture<PaymentConfirmationResult> confirmPayment({
    required String paymentId,
    required String orderId,
    required String gateway,
  });
}
