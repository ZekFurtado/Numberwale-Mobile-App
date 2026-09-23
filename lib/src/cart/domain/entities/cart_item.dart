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

  /// Category name (VIP, Fancy, Lucky, etc.), when the backend's cart
  /// response includes the nested product.
  final String? category;

  /// Numerology details (sum/liters, trap, score), when the backend's cart
  /// response includes the nested product.
  final Map<String, dynamic>? numerology;

  const CartItem({
    this.id,
    required this.productId,
    required this.productNumber,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.category,
    this.numerology,
  });

  @override
  List<Object?> get props => [id, productId];
}
