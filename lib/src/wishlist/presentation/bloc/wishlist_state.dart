part of 'wishlist_bloc.dart';

enum WishlistStatus { initial, loading, success, failure }

class WishlistState extends Equatable {
  const WishlistState({
    this.status = WishlistStatus.initial,
    this.items = const [],
    this.savedIds = const {},
    this.message,
  });

  final WishlistStatus status;

  /// The full rows, used by the wishlist page.
  final List<WishlistItem> items;

  /// Ids of everything saved — what the heart icons across the app read.
  /// Kept separate from [items] so an optimistic toggle can flip a heart
  /// before the server has confirmed and the row has been fetched.
  final Set<String> savedIds;

  /// The most recent success or failure message, for snackbars.
  final String? message;

  bool get isLoading => status == WishlistStatus.loading;

  bool isSaved(String? itemId) =>
      itemId != null && savedIds.contains(itemId);

  WishlistState copyWith({
    WishlistStatus? status,
    List<WishlistItem>? items,
    Set<String>? savedIds,
    String? message,
    bool clearMessage = false,
  }) {
    return WishlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      savedIds: savedIds ?? this.savedIds,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, items, savedIds, message];
}
