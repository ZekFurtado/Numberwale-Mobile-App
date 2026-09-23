import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/cart_validation_result.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_confirmation_result.dart';
import 'package:numberwale/src/cart/domain/entities/phonepe_verification_result.dart';
import 'package:numberwale/src/cart/domain/usecases/add_to_cart.dart';
import 'package:numberwale/src/cart/domain/usecases/checkout.dart';
import 'package:numberwale/src/cart/domain/usecases/clear_cart.dart';
import 'package:numberwale/src/cart/domain/usecases/confirm_payment.dart';
import 'package:numberwale/src/cart/domain/usecases/get_cart.dart';
import 'package:numberwale/src/cart/domain/usecases/remove_cart_item.dart';
import 'package:numberwale/src/cart/domain/usecases/validate_cart.dart';
import 'package:numberwale/src/cart/domain/usecases/verify_phonepe_payment.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCart getCart,
    required AddToCart addToCart,
    required RemoveCartItem removeCartItem,
    required ClearCart clearCart,
    required Checkout checkout,
    required ValidateCart validateCart,
    required VerifyPhonePePayment verifyPhonePePayment,
    required ConfirmPayment confirmPayment,
  })  : _getCart = getCart,
        _addToCart = addToCart,
        _removeCartItem = removeCartItem,
        _clearCart = clearCart,
        _checkout = checkout,
        _validateCart = validateCart,
        _verifyPhonePePayment = verifyPhonePePayment,
        _confirmPayment = confirmPayment,
        super(const CartInitial()) {
    on<LoadCartEvent>(_loadCartHandler);
    on<AddToCartEvent>(_addToCartHandler);
    on<RemoveCartItemEvent>(_removeCartItemHandler);
    on<ClearCartEvent>(_clearCartHandler);
    on<ValidateCartEvent>(_validateCartHandler);
    on<CheckoutEvent>(_checkoutHandler);
    on<VerifyPhonePePaymentEvent>(_verifyPhonePePaymentHandler);
    on<ConfirmPaymentEvent>(_confirmPaymentHandler);
  }

  final GetCart _getCart;
  final AddToCart _addToCart;
  final RemoveCartItem _removeCartItem;
  final ClearCart _clearCart;
  final Checkout _checkout;
  final ValidateCart _validateCart;
  final VerifyPhonePePayment _verifyPhonePePayment;
  final ConfirmPayment _confirmPayment;

  Future<void> _loadCartHandler(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());

    final result = await _getCart();

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  Future<void> _addToCartHandler(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const AddingToCart());

    final result = await _addToCart(
      AddToCartParams(productId: event.productId),
    );

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) => emit(ItemAddedToCart(cart: cart, buyNow: event.buyNow)),
    );
  }

  Future<void> _removeCartItemHandler(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await _removeCartItem(
      RemoveCartItemParams(itemId: event.itemId),
    );

    var removed = false;
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (_) {
        removed = true;
        emit(const ItemRemovedFromCart());
      },
    );

    if (removed) await _emitFreshCart(emit);
  }

  Future<void> _clearCartHandler(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await _clearCart();

    var cleared = false;
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (_) {
        cleared = true;
        emit(const CartCleared());
      },
    );

    if (cleared) await _emitFreshCart(emit);
  }

  /// Re-reads the server cart and emits it, so the UI never has to sit on a
  /// transient state waiting for someone else to trigger a refresh.
  Future<void> _emitFreshCart(Emitter<CartState> emit) async {
    final result = await _getCart();
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  Future<void> _validateCartHandler(
    ValidateCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartValidating());

    final result = await _validateCart();

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (validation) => emit(CartValidationCompleted(result: validation)),
    );
  }

  Future<void> _checkoutHandler(
    CheckoutEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CheckingOut());

    final result = await _checkout(
      CheckoutParams(
        addressId: event.addressId,
        paymentGateway: event.paymentGateway,
      ),
    );

    CheckoutResult? checkoutResult;
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (r) => checkoutResult = r,
    );

    if (checkoutResult == null) return;

    switch (event.paymentGateway) {
      case 'phonepe':
        // This backend's PhonePe integration is a hosted-page redirect (no
        // SDK token) — the app opens paymentUrl externally and later
        // verifies via /cart/verify-phonepe-payment. Cart is kept intact
        // until then.
        if (checkoutResult!.paymentUrl != null) {
          emit(PhonePeRedirectReady(
            paymentUrl: checkoutResult!.paymentUrl!,
            checkoutResult: checkoutResult!,
          ));
        } else {
          emit(const CartError(
            message:
                'PhonePe payment could not be initialized. Please try another method.',
          ));
        }
      case 'razorpay':
        // /cart/checkout only creates the order — it does not collect or
        // confirm payment. The app must open the Razorpay SDK with this
        // orderId, then call ConfirmPaymentEvent (POST /cart/payment-success)
        // once the SDK reports success. Cart is kept intact until then.
        emit(RazorpayCheckoutReady(checkoutResult: checkoutResult!));
      default:
        emit(CartError(
          message: 'Unsupported payment gateway: ${event.paymentGateway}',
        ));
    }
  }

  Future<void> _verifyPhonePePaymentHandler(
    VerifyPhonePePaymentEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const VerifyingPhonePePayment());

    // Per the API docs: retry verification 3 times with 2-second delays,
    // since PhonePe may still be processing the payment.
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await _verifyPhonePePayment(
        VerifyPhonePePaymentParams(orderId: event.orderId),
      );

      PhonePeVerificationResult? verification;
      String? failureMessage;
      result.fold(
        (failure) => failureMessage = failure.message,
        (r) => verification = r,
      );

      if (failureMessage != null) {
        emit(CartError(message: failureMessage!));
        return;
      }

      if (verification!.status != PhonePePaymentStatus.pending ||
          attempt == maxAttempts) {
        if (verification!.status == PhonePePaymentStatus.completed) {
          await _clearCart();
        }
        emit(PhonePePaymentVerified(result: verification!));
        return;
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _confirmPaymentHandler(
    ConfirmPaymentEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const ConfirmingPayment());

    final result = await _confirmPayment(
      ConfirmPaymentParams(
        paymentId: event.paymentId,
        orderId: event.orderId,
        gateway: event.gateway,
      ),
    );

    PaymentConfirmationResult? confirmation;
    String? failureMessage;
    result.fold(
      (failure) => failureMessage = failure.message,
      (r) => confirmation = r,
    );

    if (failureMessage != null) {
      emit(CartError(message: failureMessage!));
      return;
    }

    await _clearCart();
    emit(PaymentConfirmed(result: confirmation!));
  }
}
