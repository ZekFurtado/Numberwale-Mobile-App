import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/ai_search/domain/entities/ai_search_filters.dart';
import 'package:numberwale/src/ai_search/domain/repositories/ai_search_repository.dart';

/// Use case for turning a natural language query into structured filters.
class GetAiSearchFilters
    extends UseCaseWithParams<AiSearchFilters, GetAiSearchFiltersParams> {
  final AiSearchRepository _repository;

  GetAiSearchFilters(this._repository);

  @override
  ResultFuture<AiSearchFilters> call(GetAiSearchFiltersParams params) {
    return _repository.search(
      query: params.query,
      activeFilters: params.activeFilters,
    );
  }
}

class GetAiSearchFiltersParams extends Equatable {
  final String query;
  final Map<String, dynamic>? activeFilters;

  const GetAiSearchFiltersParams({required this.query, this.activeFilters});

  @override
  List<Object?> get props => [query, activeFilters];
}
