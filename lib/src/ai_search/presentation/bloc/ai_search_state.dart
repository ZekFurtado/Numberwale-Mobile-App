part of 'ai_search_bloc.dart';

abstract class AiSearchState extends Equatable {
  const AiSearchState();

  @override
  List<Object?> get props => [];
}

class AiSearchInitial extends AiSearchState {
  const AiSearchInitial();
}

class AiSearchLoading extends AiSearchState {
  const AiSearchLoading();
}

class AiSearchLoaded extends AiSearchState {
  final AiSearchFilters filters;

  const AiSearchLoaded({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class AiSearchError extends AiSearchState {
  final String message;

  const AiSearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
