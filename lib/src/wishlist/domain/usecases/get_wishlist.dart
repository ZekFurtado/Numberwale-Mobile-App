import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';
import 'package:numberwale/src/wishlist/domain/repositories/wishlist_repository.dart';

class GetWishlist extends UseCaseWithoutParams<List<WishlistItem>> {
  const GetWishlist(this._repository);

  final WishlistRepository _repository;

  @override
  ResultFuture<List<WishlistItem>> call() => _repository.getWishlist();
}
