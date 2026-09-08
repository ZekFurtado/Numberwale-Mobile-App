import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/corporate_pack/domain/entities/corporate_pack.dart';
import 'package:numberwale/src/corporate_pack/domain/usecases/get_corporate_packs.dart';

part 'corporate_pack_event.dart';
part 'corporate_pack_state.dart';

class CorporatePackBloc extends Bloc<CorporatePackEvent, CorporatePackState> {
  CorporatePackBloc({required GetCorporatePacks getCorporatePacks})
      : _getCorporatePacks = getCorporatePacks,
        super(const CorporatePackInitial()) {
    on<LoadCorporatePacksEvent>(_onLoadCorporatePacks);
    on<ShowMoreCorporatePacksEvent>(_onShowMore);
  }

  final GetCorporatePacks _getCorporatePacks;

  /// Fetched generously upfront (rather than paginated) so "Show More" is an
  /// instant client-side reveal, since the API has no offset/cursor support.
  static const _fetchLimit = 30;
  static const _initialVisible = 2;
  static const _revealStep = 2;

  Future<void> _onLoadCorporatePacks(
    LoadCorporatePacksEvent event,
    Emitter<CorporatePackState> emit,
  ) async {
    emit(const CorporatePackLoading());

    final result = await _getCorporatePacks(GetCorporatePacksParams(
      matchType: event.matchType,
      packSize: event.packSize,
      limit: _fetchLimit,
    ));

    result.fold(
      (failure) => emit(CorporatePackError(message: failure.message)),
      (packs) => emit(CorporatePackLoaded(
        packs: packs,
        visibleCount: _initialVisible.clamp(0, packs.length),
        matchType: event.matchType,
        packSize: event.packSize,
      )),
    );
  }

  void _onShowMore(
    ShowMoreCorporatePacksEvent event,
    Emitter<CorporatePackState> emit,
  ) {
    final state = this.state;
    if (state is! CorporatePackLoaded) return;

    emit(state.copyWith(
      visibleCount:
          (state.visibleCount + _revealStep).clamp(0, state.packs.length),
    ));
  }
}
