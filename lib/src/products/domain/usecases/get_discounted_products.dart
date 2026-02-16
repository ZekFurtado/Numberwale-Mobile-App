import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/repositories/product_repository.dart';

/// Use case for getting discounted products
class GetDiscountedProducts
    extends UseCaseWithParams<ProductResult, GetDiscountedProductsParams> {
  final ProductRepository _repository;

  GetDiscountedProducts(this._repository);

  @override
  ResultFuture<ProductResult> call(GetDiscountedProductsParams params) {
    return _repository.getDiscountedProducts(params.filters);
  }
}

class GetDiscountedProductsParams extends Equatable {
  final ProductFilters filters;

  const GetDiscountedProductsParams({required this.filters});

  @override
  List<Object?> get props => [filters];
}
