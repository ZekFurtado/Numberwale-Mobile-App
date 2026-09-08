import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/corporate_pack/domain/entities/corporate_pack.dart';

/// Abstract repository for Corporate Elite Pack (Jodi) operations
abstract class CorporatePackRepository {
  /// Fetches family packs (grouped VIP numbers) matching the given
  /// relation type and pack size.
  ResultFuture<List<CorporatePack>> getCorporatePacks({
    required String matchType,
    required int packSize,
    int limit = 30,
  });
}
