import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/ai_search/domain/entities/ai_search_filters.dart';
import 'package:numberwale/src/ai_search/domain/usecases/get_ai_search_filters.dart';

part 'ai_search_event.dart';
part 'ai_search_state.dart';

class AiSearchBloc extends Bloc<AiSearchEvent, AiSearchState> {
  final GetAiSearchFilters _getAiSearchFilters;

  AiSearchBloc({required GetAiSearchFilters getAiSearchFilters})
      : _getAiSearchFilters = getAiSearchFilters,
        super(const AiSearchInitial()) {
    on<RunAiSearchEvent>(_onRunAiSearch);
    on<ClearAiSearchEvent>(_onClearAiSearch);
  }

  Future<void> _onRunAiSearch(
    RunAiSearchEvent event,
    Emitter<AiSearchState> emit,
  ) async {
    emit(const AiSearchLoading());

    final result = await _getAiSearchFilters(
      GetAiSearchFiltersParams(
        query: event.query,
        activeFilters: event.activeFilters,
      ),
    );

    result.fold(
      (failure) => emit(AiSearchError(message: failure.message)),
      (filters) => emit(AiSearchLoaded(filters: filters)),
    );
  }

  void _onClearAiSearch(
    ClearAiSearchEvent event,
    Emitter<AiSearchState> emit,
  ) {
    emit(const AiSearchInitial());
  }
}
