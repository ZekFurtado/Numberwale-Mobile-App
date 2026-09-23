import 'dart:developer';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/cart_item.dart';

/// The model of the CartItem class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class CartItemModel extends CartItem {
  const CartItemModel({
    super.id,
    required super.productId,
    required super.productNumber,
    required super.price,
    required super.quantity,
    super.imageUrl,
    super.category,
    super.numerology,
  });

  /// Creates a CartItemModel from a Map.
  ///
  /// Handles three shapes:
  ///   1. Cart-item map with a nested `product` object  → { _id, quantity, product: {...} }
  ///   2. Flat cart-item map                            → { productId, productNumber, price, quantity }
  ///   3. Raw product object from addToCart response    → { _id, productMobileNumber, pricing: {...} }
  factory CartItemModel.fromMap(DataMap map) {
    log('CartItemModel.fromMap keys: ${map.keys.toList()}');

    // Shape 1: cart item with nested product
    final product = map['product'] as DataMap?;

    // Shape 3: map IS the product object (has _id + productMobileNumber or pricing)
    final bool isProductObject = product == null &&
        (map.containsKey('productMobileNumber') ||
            map.containsKey('pricing') ||
            (map.containsKey('_id') && !map.containsKey('productId')));

    // Resolve the actual product-level map
    final DataMap productMap = product ?? (isProductObject ? map : const {});

    final productId = productMap.isNotEmpty
        ? (productMap['_id'] as String? ?? productMap['id'] as String? ?? '')
        : (map['productId'] as String? ?? map['product_id'] as String? ?? '');

    final productNumber = productMap.isNotEmpty
        ? (productMap['productMobileNumber'] as String?
            ?? productMap['mobileNumber'] as String?
            ?? productMap['number'] as String?
            ?? productMap['phoneNumber'] as String?
            ?? '')
        : (map['productNumber'] as String?
            ?? map['product_number'] as String?
            ?? map['mobileNumber'] as String?
            ?? map['number'] as String?
            ?? '');

    final pricing = productMap['pricing'] as DataMap?;
    final double price;
    if (pricing != null) {
      price = ((pricing['nwFinalPrice']
              ?? pricing['finalPrice']
              ?? pricing['sellingPrice']
              ?? pricing['price']) as num? ?? 0)
          .toDouble();
    } else {
      price = (map['price'] as num? ?? map['sellingPrice'] as num? ?? 0)
          .toDouble();
    }

    // id for the cart item row (not the product id)
    final String? itemId = isProductObject
        ? null // product object has no cart-row id yet
        : (map['_id'] as String? ?? map['id'] as String?);

    // Category and numerology (SUM/TRAP/SCORE) — same shape as the products
    // API's product object, parsed the same way as
    // HomeRemoteDataSourceImpl._parseProduct.
    final DataMap sourceMap = productMap.isNotEmpty ? productMap : map;
    String? categoryName;
    final categoryRaw = sourceMap['category'];
    if (categoryRaw is Map) {
      categoryName = categoryRaw['name'] as String?;
    } else if (categoryRaw is String && categoryRaw.isNotEmpty) {
      categoryName = categoryRaw;
    }

    final numerologyMap = <String, dynamic>{
      ...?(sourceMap['numerology'] as DataMap?),
      if (sourceMap['liters'] != null) 'liters': sourceMap['liters'],
      if (sourceMap['trap'] != null) 'trap': sourceMap['trap'],
      if (sourceMap['score'] != null) 'score': sourceMap['score'],
    };

    return CartItemModel(
      id: itemId,
      productId: productId,
      productNumber: productNumber,
      price: price,
      quantity: (map['quantity'] as num? ?? 1).toInt(),
      imageUrl: map['imageUrl'] as String? ?? map['image_url'] as String?,
      category: categoryName,
      numerology: numerologyMap.isEmpty ? null : numerologyMap,
    );
  }
}
