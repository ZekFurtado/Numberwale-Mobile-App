part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the current cart
class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

/// Event to add a product to the cart
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

/// Event to remove a specific item from the cart
class RemoveCartItemEvent extends CartEvent {
  const RemoveCartItemEvent({required this.itemId});

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

/// Event to clear all items from the cart
class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

/// Event to initiate checkout
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

/// Event to confirm a payment after successful gateway transaction
class ConfirmPaymentEvent extends CartEvent {
  const ConfirmPaymentEvent({
    required this.paymentId,
    required this.orderId,
    required this.gateway,
    this.signature,
  });

  final String paymentId;
  final String orderId;
  final String gateway;

  /// Razorpay payment signature for backend verification.
  final String? signature;

  @override
  List<Object?> get props => [paymentId, orderId, gateway, signature];
}

/// Event to load available payment gateways
class GetPaymentGatewaysEvent extends CartEvent {
  const GetPaymentGatewaysEvent();
}

/// Event to verify a PhonePe payment after SDK callback
class VerifyPhonePePaymentEvent extends CartEvent {
  const VerifyPhonePePaymentEvent({
    required this.transactionId,
    required this.orderId,
  });

  final String transactionId;
  final String orderId;

  @override
  List<Object> get props => [transactionId, orderId];
}
