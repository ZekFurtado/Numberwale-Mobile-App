import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/entities/similar_number_filters.dart';

/// Abstract repository for product operations
abstract class ProductRepository {
  /// Get products with optional filters and pagination
  ResultFuture<ProductResult> getProducts(ProductFilters filters);

  /// Get discounted products
  ResultFuture<ProductResult> getDiscountedProducts(ProductFilters filters);

  /// Get a specific product by its mobile number
  ResultFuture<PhoneNumber> getProductByNumber(String number);

  /// Get numbers similar to a given prefix/suffix/both-ends digit pattern
  ResultFuture<ProductResult> getSimilarProducts(SimilarNumberFilters filters);
}
