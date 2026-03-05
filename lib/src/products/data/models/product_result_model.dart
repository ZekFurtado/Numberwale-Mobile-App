import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/products/data/models/product_model.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';

/// The model for a paginated product result from the Products API
class ProductResultModel extends ProductResult {
  const ProductResultModel({
    required super.products,
    required super.totalCount,
    required super.currentPage,
    required super.totalPages,
    required super.itemsPerPage,
    required super.hasNextPage,
    required super.hasPrevPage,
    super.seed,
  });

  factory ProductResultModel.fromMap(DataMap map) {
    final metadata = map['metadata'] as DataMap? ?? {};
    // Products are at root level: { "metadata": {...}, "products": [...] }
    final productsRaw = map['products'] as List<dynamic>? ?? [];

    final currentPage = (metadata['currentPage'] as num?)?.toInt() ?? 1;
    final totalPages = (metadata['totalPages'] as num?)?.toInt() ?? 0;

    return ProductResultModel(
      products: productsRaw
          .map((p) => ProductModel.fromMap(p as DataMap))
          .toList(),
      totalCount: (metadata['totalCount'] as num?)?.toInt() ?? 0,
      currentPage: currentPage,
      totalPages: totalPages,
      itemsPerPage: (metadata['itemsPerPage'] as num?)?.toInt() ?? 20,
      hasNextPage: currentPage < totalPages,
      hasPrevPage: currentPage > 1,
      seed: metadata['seed'] as String?,
    );
  }
}
