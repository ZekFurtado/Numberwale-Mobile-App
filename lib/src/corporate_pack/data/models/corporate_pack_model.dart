import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/corporate_pack/domain/entities/corporate_pack.dart';
import 'package:numberwale/src/products/data/models/product_model.dart';

/// Model for a Corporate Elite Pack from `GET /api/v1/family-packs/with-products`.
class CorporatePackModel extends CorporatePack {
  const CorporatePackModel({
    required super.id,
    required super.type,
    required super.value,
    required super.products,
    super.createdAt,
  });

  factory CorporatePackModel.fromMap(DataMap map) {
    final productsRaw = map['products'] as List<dynamic>? ?? [];
    return CorporatePackModel(
      id: map['_id'] as String? ?? '',
      type: map['type'] as String? ?? 'Series',
      value: map['value'] as String? ?? '',
      products: productsRaw
          .map((p) => ProductModel.fromMap(p as DataMap))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}
