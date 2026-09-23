import 'package:dartz/dartz.dart';
import 'package:numberwale/core/errors/exceptions.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';
import 'package:numberwale/src/wishlist/domain/repositories/wishlist_repository.dart';

/// Thin pass-through to the server-side wishlist — the server is the source
/// of truth, so nothing is cached locally.
class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<WishlistItem>> getWishlist() async {
    try {
      return Right(await remoteDataSource.getWishlist());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultVoid addToWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  }) async {
    try {
      await remoteDataSource.addToWishlist(
        itemId: itemId,
        type: type,
        packSize: packSize,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultVoid removeFromWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  }) async {
    try {
      await remoteDataSource.removeFromWishlist(
        itemId: itemId,
        type: type,
        packSize: packSize,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
