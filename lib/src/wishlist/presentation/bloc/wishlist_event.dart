part of 'wishlist_bloc.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the wishlist from the server.
class LoadWishlistEvent extends WishlistEvent {
  const LoadWishlistEvent();
}

/// Saves the item if it isn't saved yet, removes it if it is.
class ToggleWishlistEvent extends WishlistEvent {
  const ToggleWishlistEvent({
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

/// Drops everything held in memory — dispatched on sign-out so the next
/// account doesn't briefly see the previous one's saved numbers.
class ClearWishlistCacheEvent extends WishlistEvent {
  const ClearWishlistCacheEvent();
}
