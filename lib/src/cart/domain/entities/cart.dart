import 'package:equatable/equatable.dart';
import 'package:numberwale/src/cart/domain/entities/cart_item.dart';

/// Represents the shopping cart
class Cart extends Equatable {
  /// Unique ID of the cart
  final String? id;

  /// List of items in the cart
  final List<CartItem> items;

  /// Total amount for the cart
  final double totalAmount;

  /// Total number of items in the cart
  final int itemCount;

  /// Subtotal before taxes
  final double subtotal;

  /// Total tax amount
  final double taxAmount;

  /// Central GST component
  final double cgst;

  /// State GST component
  final double sgst;

  const Cart({
    this.id,
    required this.items,
    required this.totalAmount,
    required this.itemCount,
    required this.subtotal,
    required this.taxAmount,
    required this.cgst,
    required this.sgst,
  });

  /// Returns true if the cart has no items
  bool get isEmpty => items.isEmpty;

  /// Returns true if the cart has at least one item
  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [id, items, totalAmount];
}
