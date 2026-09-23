import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/products/data/models/product_model.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';

/// Model for one row of `GET /api/v1/wishlist`.
///
/// Rows are shaped `{ itemType, number: {...} }` for a saved product and
/// `{ itemType, pack: { products: [...] } }` for a saved Corporate Elite Pack.
/// Rows whose referenced product/pack no longer exists come back with both
/// keys null — [fromMap] returns null for those so they can be dropped.
class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.id,
    required super.type,
    required super.numbers,
    super.packType,
    super.packValue,
  });

  static WishlistItemModel? fromMap(DataMap map) {
    final type = WishlistItemTypeX.fromApi(map['itemType'] as String?);

    if (type == WishlistItemType.pack) {
      final pack = map['pack'] as DataMap?;
      if (pack == null) return null;
      final productsRaw = pack['products'] as List<dynamic>? ?? const [];
      return WishlistItemModel(
        id: pack['_id'] as String? ?? '',
        type: WishlistItemType.pack,
        numbers: productsRaw
            .map((p) => ProductModel.fromMap(p as DataMap))
            .toList(),
        packType: pack['type'] as String?,
        packValue: pack['value'] as String?,
      );
    }

    final number = map['number'] as DataMap?;
    if (number == null) return null;
    final product = ProductModel.fromMap(number);
    return WishlistItemModel(
      id: product.id ?? number['_id'] as String? ?? '',
      type: WishlistItemType.product,
      numbers: [product],
    );
  }
}
