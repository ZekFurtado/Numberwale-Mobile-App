import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';

/// Abstract repository for product operations
abstract class ProductRepository {
  /// Get products with optional filters and pagination
  ResultFuture<ProductResult> getProducts(ProductFilters filters);

  /// Get discounted products
  ResultFuture<ProductResult> getDiscountedProducts(ProductFilters filters);

  /// Get a specific product by its mobile number
  ResultFuture<PhoneNumber> getProductByNumber(String number);
}
