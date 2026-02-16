import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/repositories/product_repository.dart';

/// Use case for getting a paginated, filtered list of products
class GetProducts extends UseCaseWithParams<ProductResult, GetProductsParams> {
  final ProductRepository _repository;

  GetProducts(this._repository);

  @override
  ResultFuture<ProductResult> call(GetProductsParams params) {
    return _repository.getProducts(params.filters);
  }
}

class GetProductsParams extends Equatable {
  final ProductFilters filters;

  const GetProductsParams({required this.filters});

  @override
  List<Object?> get props => [filters];
}
