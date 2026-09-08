part of 'corporate_pack_bloc.dart';

abstract class CorporatePackEvent extends Equatable {
  const CorporatePackEvent();

  @override
  List<Object?> get props => [];
}

/// Loads packs for the given relation type and pack size, resetting the
/// "Show More" reveal count.
class LoadCorporatePacksEvent extends CorporatePackEvent {
  final String matchType;
  final int packSize;

  const LoadCorporatePacksEvent({
    required this.matchType,
    required this.packSize,
  });

  @override
  List<Object?> get props => [matchType, packSize];
}

/// Reveals the next batch of already-fetched packs.
class ShowMoreCorporatePacksEvent extends CorporatePackEvent {
  const ShowMoreCorporatePacksEvent();
}
