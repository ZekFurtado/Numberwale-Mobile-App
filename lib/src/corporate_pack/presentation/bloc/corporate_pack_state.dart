part of 'corporate_pack_bloc.dart';

abstract class CorporatePackState extends Equatable {
  const CorporatePackState();

  @override
  List<Object?> get props => [];
}

class CorporatePackInitial extends CorporatePackState {
  const CorporatePackInitial();
}

class CorporatePackLoading extends CorporatePackState {
  const CorporatePackLoading();
}

class CorporatePackLoaded extends CorporatePackState {
  const CorporatePackLoaded({
    required this.packs,
    required this.visibleCount,
    required this.matchType,
    required this.packSize,
  });

  final List<CorporatePack> packs;
  final int visibleCount;
  final String matchType;
  final int packSize;

  List<CorporatePack> get visiblePacks => packs.take(visibleCount).toList();

  int get remainingCount => packs.length - visibleCount;

  bool get hasMore => remainingCount > 0;

  CorporatePackLoaded copyWith({
    List<CorporatePack>? packs,
    int? visibleCount,
    String? matchType,
    int? packSize,
  }) {
    return CorporatePackLoaded(
      packs: packs ?? this.packs,
      visibleCount: visibleCount ?? this.visibleCount,
      matchType: matchType ?? this.matchType,
      packSize: packSize ?? this.packSize,
    );
  }

  @override
  List<Object?> get props => [packs, visibleCount, matchType, packSize];
}

class CorporatePackError extends CorporatePackState {
  const CorporatePackError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
