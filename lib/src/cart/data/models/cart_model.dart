import 'dart:developer';

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
    // ignore: avoid_print
    print('CartModel.fromMap top-level keys: ${map.keys.toList()}');

    // Handle various nesting: { cart: {...} }, { data: { cart: {...} } }, or flat
    DataMap cartData = map;
    if (map['cart'] is DataMap) {
      cartData = map['cart'] as DataMap;
    } else if (map['data'] is DataMap) {
      final inner = map['data'] as DataMap;
      cartData = inner['cart'] is DataMap ? inner['cart'] as DataMap : inner;
    }
    // ignore: avoid_print
    print('CartModel cartData keys: ${cartData.keys.toList()}');

    // Try every plausible key name for the items array
    final rawItems = (cartData['items']
        ?? cartData['cartItems']
        ?? cartData['cart_items']
        ?? cartData['products']
        ?? cartData['lineItems']) as List<dynamic>? ?? [];
    // ignore: avoid_print
    print('CartModel rawItems count: ${rawItems.length}');
    final items = rawItems
        .map((item) => CartItemModel.fromMap(item as DataMap))
        .toList();

    final gst = cartData['gst'] as DataMap?;
    final tax = cartData['tax'] as DataMap?;

    double toDouble(dynamic v) => (v as num? ?? 0).toDouble();

    return CartModel(
      id: cartData['_id'] as String?
          ?? cartData['id'] as String?
          ?? cartData['cartId'] as String?,
      items: items,
      totalAmount: toDouble(cartData['totalAmount']
          ?? cartData['total_amount']
          ?? cartData['total']),
      itemCount: (cartData['itemCount'] as num?
          ?? cartData['item_count'] as num?
          ?? items.length).toInt(),
      subtotal: toDouble(cartData['subtotal']
          ?? cartData['subTotal']
          ?? cartData['sub_total']),
      taxAmount: toDouble(cartData['taxAmount']
          ?? cartData['tax_amount']
          ?? cartData['totalTax']),
      cgst: gst != null
          ? toDouble(gst['cgst'])
          : tax != null
              ? toDouble(tax['cgst'])
              : toDouble(cartData['cgst']),
      sgst: gst != null
          ? toDouble(gst['sgst'])
          : tax != null
              ? toDouble(tax['sgst'])
              : toDouble(cartData['sgst']),
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
