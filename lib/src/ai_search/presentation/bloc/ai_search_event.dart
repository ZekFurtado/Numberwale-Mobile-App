part of 'ai_search_bloc.dart';

abstract class AiSearchEvent extends Equatable {
  const AiSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Send a natural language query (with the currently active filters, for
/// context) to be parsed into structured filters.
class RunAiSearchEvent extends AiSearchEvent {
  final String query;
  final Map<String, dynamic>? activeFilters;

  const RunAiSearchEvent({required this.query, this.activeFilters});

  @override
  List<Object?> get props => [query, activeFilters];
}

/// Reset back to the initial (no query) state.
class ClearAiSearchEvent extends AiSearchEvent {
  const ClearAiSearchEvent();
}
