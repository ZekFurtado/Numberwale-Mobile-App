import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/data/models/cart_item_model.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';

/// The model of the Cart class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class CartModel extends Cart {
  const CartModel({
    super.id,
    required super.items,
    required super.totalAmount,
    required super.itemCount,
    required super.subtotal,
    required super.taxAmount,
    required super.cgst,
    required super.sgst,
  });

  /// Creates a CartModel from a Map
  factory CartModel.fromMap(DataMap map) {
    // The cart may be wrapped under a 'cart' key inside 'data'
    final cartData = map['cart'] as DataMap? ?? map;

    final rawItems = cartData['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((item) => CartItemModel.fromMap(item as DataMap))
        .toList();

    final gst = cartData['gst'] as DataMap?;

    return CartModel(
      id: cartData['_id'] as String? ?? cartData['id'] as String?,
      items: items,
      totalAmount: (cartData['totalAmount'] as num? ?? 0).toDouble(),
      itemCount: (cartData['itemCount'] as num? ?? items.length).toInt(),
      subtotal: (cartData['subtotal'] as num? ?? 0).toDouble(),
      taxAmount: (cartData['taxAmount'] as num? ?? 0).toDouble(),
      cgst: gst != null
          ? (gst['cgst'] as num? ?? 0).toDouble()
          : (cartData['cgst'] as num? ?? 0).toDouble(),
      sgst: gst != null
          ? (gst['sgst'] as num? ?? 0).toDouble()
          : (cartData['sgst'] as num? ?? 0).toDouble(),
    );
  }

  /// Converts this CartModel to a Map
  DataMap toMap() {
    return {
      if (id != null) '_id': id,
      'items': items
          .map((item) => (item as CartItemModel).toMap())
          .toList(),
      'totalAmount': totalAmount,
      'itemCount': itemCount,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'gst': {
        'cgst': cgst,
        'sgst': sgst,
      },
    };
  }
}
