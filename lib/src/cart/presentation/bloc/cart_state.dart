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

class CheckoutComplete extends CartState {
  const CheckoutComplete({required this.result});

  final CheckoutResult result;

  @override
  List<Object> get props => [result];
}
