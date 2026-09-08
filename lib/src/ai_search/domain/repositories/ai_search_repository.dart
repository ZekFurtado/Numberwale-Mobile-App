import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/ai_search/domain/entities/ai_search_filters.dart';

/// Repository for the AI-powered natural language search.
abstract class AiSearchRepository {
  /// Sends [query] (and any currently [activeFilters], so the AI knows
  /// whether the user is refining an existing search) and returns the
  /// structured filters extracted from it.
  ResultFuture<AiSearchFilters> search({
    required String query,
    Map<String, dynamic>? activeFilters,
  });
}
