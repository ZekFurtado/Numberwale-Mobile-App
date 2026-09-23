import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';
import 'package:numberwale/src/wishlist/domain/repositories/wishlist_repository.dart';

class AddToWishlist extends UseCaseWithParams<void, WishlistItemParams> {
  const AddToWishlist(this._repository);

  final WishlistRepository _repository;

  @override
  ResultVoid call(WishlistItemParams params) => _repository.addToWishlist(
        itemId: params.itemId,
        type: params.type,
        packSize: params.packSize,
      );
}

class WishlistItemParams extends Equatable {
  const WishlistItemParams({
    required this.itemId,
    this.type = WishlistItemType.product,
    this.packSize,
  });

  final String itemId;
  final WishlistItemType type;
  final int? packSize;

  @override
  List<Object?> get props => [itemId, type, packSize];
}
