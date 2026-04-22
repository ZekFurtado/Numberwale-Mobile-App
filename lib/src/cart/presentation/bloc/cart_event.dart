part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

class AddToCartEvent extends CartEvent {
  const AddToCartEvent({
    required this.productId,
    required this.productNumber,
    required this.price,
  });

  final String productId;
  final String productNumber;
  final double price;

  @override
  List<Object> get props => [productId, productNumber, price];
}

class RemoveCartItemEvent extends CartEvent {
  const RemoveCartItemEvent({required this.itemId});

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

class CheckoutEvent extends CartEvent {
  const CheckoutEvent({
    required this.addressId,
    required this.paymentGateway,
  });

  final String addressId;
  final String paymentGateway;

  @override
  List<Object> get props => [addressId, paymentGateway];
}
