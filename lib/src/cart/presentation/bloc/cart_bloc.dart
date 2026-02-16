import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_gateway.dart';
import 'package:numberwale/src/cart/domain/usecases/add_to_cart.dart';
import 'package:numberwale/src/cart/domain/usecases/checkout.dart';
import 'package:numberwale/src/cart/domain/usecases/clear_cart.dart';
import 'package:numberwale/src/cart/domain/usecases/confirm_payment.dart';
import 'package:numberwale/src/cart/domain/usecases/get_cart.dart';
import 'package:numberwale/src/cart/domain/usecases/get_payment_gateways.dart';
import 'package:numberwale/src/cart/domain/usecases/remove_cart_item.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCart getCart,
    required AddToCart addToCart,
    required RemoveCartItem removeCartItem,
    required ClearCart clearCart,
    required Checkout checkout,
    required ConfirmPayment confirmPayment,
    required GetPaymentGateways getPaymentGateways,
  })  : _getCart = getCart,
        _addToCart = addToCart,
        _removeCartItem = removeCartItem,
        _clearCart = clearCart,
        _checkout = checkout,
        _confirmPayment = confirmPayment,
        _getPaymentGateways = getPaymentGateways,
        super(const CartInitial()) {
    on<LoadCartEvent>(_loadCartHandler);
    on<AddToCartEvent>(_addToCartHandler);
    on<RemoveCartItemEvent>(_removeCartItemHandler);
    on<ClearCartEvent>(_clearCartHandler);
    on<CheckoutEvent>(_checkoutHandler);
    on<ConfirmPaymentEvent>(_confirmPaymentHandler);
    on<GetPaymentGatewaysEvent>(_getPaymentGatewaysHandler);
  }

  final GetCart _getCart;
  final AddToCart _addToCart;
  final RemoveCartItem _removeCartItem;
  final ClearCart _clearCart;
  final Checkout _checkout;
  final ConfirmPayment _confirmPayment;
  final GetPaymentGateways _getPaymentGateways;

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
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  Future<void> _removeCartItemHandler(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await _removeCartItem(
      RemoveCartItemParams(itemId: event.itemId),
    );

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (_) => emit(const ItemRemovedFromCart()),
    );
  }

  Future<void> _clearCartHandler(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await _clearCart();

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (_) => emit(const CartCleared()),
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

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (checkoutResult) => emit(CheckoutInitiated(result: checkoutResult)),
    );
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

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (_) => emit(const PaymentConfirmed()),
    );
  }

  Future<void> _getPaymentGatewaysHandler(
    GetPaymentGatewaysEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const LoadingPaymentGateways());

    final result = await _getPaymentGateways();

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (gateways) => emit(PaymentGatewaysLoaded(gateways: gateways)),
    );
  }
}
