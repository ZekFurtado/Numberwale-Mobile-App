import 'package:equatable/equatable.dart';

/// Represents a single item in the shopping cart
class CartItem extends Equatable {
  /// Unique ID of the cart item
  final String? id;

  /// ID of the product
  final String productId;

  /// Mobile number being purchased
  final String productNumber;

  /// Price of this item
  final double price;

  /// Quantity of this item
  final int quantity;

  /// Optional image URL for the product
  final String? imageUrl;

  const CartItem({
    this.id,
    required this.productId,
    required this.productNumber,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, productId];
}
