import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistRepository {
  ResultFuture<List<WishlistItem>> getWishlist();

  ResultVoid addToWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  });

  ResultVoid removeFromWishlist({
    required String itemId,
    required WishlistItemType type,
    int? packSize,
  });
}
