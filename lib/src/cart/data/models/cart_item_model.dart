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
  });

  /// Creates a CartItemModel from a Map
  factory CartItemModel.fromMap(DataMap map) {
    // The product field may be nested or flat
    final product = map['product'] as DataMap?;

    final productId = product != null
        ? (product['_id'] as String? ?? product['id'] as String? ?? '')
        : (map['productId'] as String? ?? map['product_id'] as String? ?? '');

    final productNumber = product != null
        ? (product['productMobileNumber'] as String? ?? '')
        : (map['productNumber'] as String? ??
            map['product_number'] as String? ??
            '');

    final pricing = product != null ? product['pricing'] as DataMap? : null;
    final price = pricing != null
        ? (pricing['nwFinalPrice'] as num? ?? 0).toDouble()
        : (map['price'] as num? ?? 0).toDouble();

    return CartItemModel(
      id: map['_id'] as String? ?? map['id'] as String?,
      productId: productId,
      productNumber: productNumber,
      price: price,
      quantity: (map['quantity'] as num? ?? 1).toInt(),
      imageUrl: map['imageUrl'] as String? ?? map['image_url'] as String?,
    );
  }

  /// Converts this CartItemModel to a Map
  DataMap toMap() {
    return {
      if (id != null) '_id': id,
      'productId': productId,
      'productNumber': productNumber,
      'price': price,
      'quantity': quantity,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
