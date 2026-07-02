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
  const AddToCartEvent({required this.productId});

  final String productId;

  @override
  List<Object> get props => [productId];
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

class ValidateCartEvent extends CartEvent {
  const ValidateCartEvent();
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

class VerifyPhonePePaymentEvent extends CartEvent {
  const VerifyPhonePePaymentEvent({required this.orderId});

  final String orderId;

  @override
  List<Object> get props => [orderId];
}

class ConfirmPaymentEvent extends CartEvent {
  const ConfirmPaymentEvent({
    required this.paymentId,
    required this.orderId,
    required this.gateway,
  });

  final String paymentId;
  final String orderId;
  final String gateway;

  @override
  List<Object> get props => [paymentId, orderId, gateway];
}
