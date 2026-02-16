part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any cart action has been taken
class CartInitial extends CartState {
  const CartInitial();
}

/// Loading the cart
class CartLoading extends CartState {
  const CartLoading();
}

/// Cart loaded successfully
class CartLoaded extends CartState {
  const CartLoaded({required this.cart});

  final Cart cart;

  @override
  List<Object> get props => [cart];
}

/// An error occurred during a cart operation
class CartError extends CartState {
  const CartError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// Adding a product to the cart
class AddingToCart extends CartState {
  const AddingToCart();
}

/// An item has been successfully removed from the cart
class ItemRemovedFromCart extends CartState {
  const ItemRemovedFromCart();
}

/// The cart has been cleared
class CartCleared extends CartState {
  const CartCleared();
}

/// Checkout is in progress
class CheckingOut extends CartState {
  const CheckingOut();
}

/// Checkout initiated successfully — payment can proceed
class CheckoutInitiated extends CartState {
  const CheckoutInitiated({required this.result});

  final CheckoutResult result;

  @override
  List<Object> get props => [result];
}

/// Payment confirmation is in progress
class ConfirmingPayment extends CartState {
  const ConfirmingPayment();
}

/// Payment confirmed successfully
class PaymentConfirmed extends CartState {
  const PaymentConfirmed();
}

/// Loading available payment gateways
class LoadingPaymentGateways extends CartState {
  const LoadingPaymentGateways();
}

/// Payment gateways loaded successfully
class PaymentGatewaysLoaded extends CartState {
  const PaymentGatewaysLoaded({required this.gateways});

  final List<PaymentGateway> gateways;

  @override
  List<Object> get props => [gateways];
}
