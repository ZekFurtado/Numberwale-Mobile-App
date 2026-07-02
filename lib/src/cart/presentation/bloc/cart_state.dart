part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  const CartLoaded({required this.cart});

  final Cart cart;

  @override
  List<Object> get props => [cart];
}

class CartError extends CartState {
  const CartError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

class AddingToCart extends CartState {
  const AddingToCart();
}

class ItemRemovedFromCart extends CartState {
  const ItemRemovedFromCart();
}

class CartCleared extends CartState {
  const CartCleared();
}

class CheckingOut extends CartState {
  const CheckingOut();
}

class CartValidating extends CartState {
  const CartValidating();
}

class CartValidationCompleted extends CartState {
  const CartValidationCompleted({required this.result});

  final CartValidationResult result;

  @override
  List<Object> get props => [result];
}

class CheckoutComplete extends CartState {
  const CheckoutComplete({required this.result});

  final CheckoutResult result;

  @override
  List<Object> get props => [result];
}

/// Emitted when the backend has created a PhonePe order and returned a
/// hosted payment page URL. The app must open [paymentUrl] externally
/// (browser/WebView) — there is no SDK token flow with this backend.
/// The cart is NOT cleared yet.
class PhonePeRedirectReady extends CartState {
  const PhonePeRedirectReady({
    required this.paymentUrl,
    required this.checkoutResult,
  });

  final String paymentUrl;
  final CheckoutResult checkoutResult;

  @override
  List<Object> get props => [paymentUrl, checkoutResult];
}

class VerifyingPhonePePayment extends CartState {
  const VerifyingPhonePePayment();
}

class PhonePePaymentVerified extends CartState {
  const PhonePePaymentVerified({required this.result});

  final PhonePeVerificationResult result;

  @override
  List<Object> get props => [result];
}

/// Emitted when the backend has created a Razorpay order. The app must open
/// the Razorpay SDK checkout with [checkoutResult]'s orderId — there is no
/// separate token. The cart is NOT cleared yet; that only happens once
/// ConfirmPaymentEvent (POST /cart/payment-success) succeeds.
class RazorpayCheckoutReady extends CartState {
  const RazorpayCheckoutReady({required this.checkoutResult});

  final CheckoutResult checkoutResult;

  @override
  List<Object> get props => [checkoutResult];
}

class ConfirmingPayment extends CartState {
  const ConfirmingPayment();
}

class PaymentConfirmed extends CartState {
  const PaymentConfirmed({required this.result});

  final PaymentConfirmationResult result;

  @override
  List<Object> get props => [result];
}
