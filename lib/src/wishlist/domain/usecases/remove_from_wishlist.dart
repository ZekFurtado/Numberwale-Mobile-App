import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/wishlist/domain/usecases/add_to_wishlist.dart';
import 'package:numberwale/src/wishlist/domain/repositories/wishlist_repository.dart';

class RemoveFromWishlist extends UseCaseWithParams<void, WishlistItemParams> {
  const RemoveFromWishlist(this._repository);

  final WishlistRepository _repository;

  @override
  ResultVoid call(WishlistItemParams params) => _repository.removeFromWishlist(
        itemId: params.itemId,
        type: params.type,
        packSize: params.packSize,
      );
}
