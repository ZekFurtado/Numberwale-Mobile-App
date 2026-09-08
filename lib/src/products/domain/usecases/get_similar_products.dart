import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/entities/similar_number_filters.dart';
import 'package:numberwale/src/products/domain/repositories/product_repository.dart';

/// Use case for getting numbers similar to a prefix/suffix digit pattern
class GetSimilarProducts
    extends UseCaseWithParams<ProductResult, GetSimilarProductsParams> {
  final ProductRepository _repository;

  GetSimilarProducts(this._repository);

  @override
  ResultFuture<ProductResult> call(GetSimilarProductsParams params) {
    return _repository.getSimilarProducts(params.filters);
  }
}

class GetSimilarProductsParams extends Equatable {
  final SimilarNumberFilters filters;

  const GetSimilarProductsParams({required this.filters});

  @override
  List<Object?> get props => [filters];
}
