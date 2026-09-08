import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/corporate_pack/domain/entities/corporate_pack.dart';
import 'package:numberwale/src/corporate_pack/domain/repositories/corporate_pack_repository.dart';

class GetCorporatePacks
    extends UseCaseWithParams<List<CorporatePack>, GetCorporatePacksParams> {
  final CorporatePackRepository repository;

  GetCorporatePacks(this.repository);

  @override
  ResultFuture<List<CorporatePack>> call(GetCorporatePacksParams params) {
    return repository.getCorporatePacks(
      matchType: params.matchType,
      packSize: params.packSize,
      limit: params.limit,
    );
  }
}

class GetCorporatePacksParams extends Equatable {
  final String matchType;
  final int packSize;
  final int limit;

  const GetCorporatePacksParams({
    required this.matchType,
    required this.packSize,
    this.limit = 30,
  });

  @override
  List<Object?> get props => [matchType, packSize, limit];
}
