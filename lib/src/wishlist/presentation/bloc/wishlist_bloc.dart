import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';
import 'package:numberwale/src/wishlist/domain/usecases/add_to_wishlist.dart';
import 'package:numberwale/src/wishlist/domain/usecases/get_wishlist.dart';
import 'package:numberwale/src/wishlist/domain/usecases/remove_from_wishlist.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

/// App-wide wishlist. Every heart icon in the app reads [WishlistState.isSaved]
/// off this bloc and dispatches [ToggleWishlistEvent], so a number saved on one
/// screen shows as saved everywhere else.
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc({
    required GetWishlist getWishlist,
    required AddToWishlist addToWishlist,
    required RemoveFromWishlist removeFromWishlist,
  })  : _getWishlist = getWishlist,
        _addToWishlist = addToWishlist,
        _removeFromWishlist = removeFromWishlist,
        super(const WishlistState()) {
    on<LoadWishlistEvent>(_onLoad);
    on<ToggleWishlistEvent>(_onToggle);
    on<ClearWishlistCacheEvent>(
      (_, emit) => emit(const WishlistState()),
    );
  }

  final GetWishlist _getWishlist;
  final AddToWishlist _addToWishlist;
  final RemoveFromWishlist _removeFromWishlist;

  Future<void> _onLoad(
    LoadWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    emit(state.copyWith(status: WishlistStatus.loading, clearMessage: true));

    final result = await _getWishlist();

    result.fold(
      (failure) {
        log('WishlistBloc: load failed — ${failure.message}');
        emit(state.copyWith(
          status: WishlistStatus.failure,
          message: failure.message,
        ));
      },
      (items) => emit(state.copyWith(
        status: WishlistStatus.success,
        items: items,
        savedIds: items.map((i) => i.id).toSet(),
        clearMessage: true,
      )),
    );
  }

  Future<void> _onToggle(
    ToggleWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final wasSaved = state.isSaved(event.itemId);
    final params = WishlistItemParams(
      itemId: event.itemId,
      type: event.type,
      packSize: event.packSize,
    );

    // Flip the heart immediately; the server call follows.
    final optimisticIds = {...state.savedIds};
    final optimisticItems = [...state.items];
    if (wasSaved) {
      optimisticIds.remove(event.itemId);
      optimisticItems.removeWhere((i) => i.id == event.itemId);
    } else {
      optimisticIds.add(event.itemId);
    }
    emit(state.copyWith(
      savedIds: optimisticIds,
      items: optimisticItems,
      clearMessage: true,
    ));

    final result =
        wasSaved ? await _removeFromWishlist(params) : await _addToWishlist(params);

    await result.fold(
      (failure) async {
        log('WishlistBloc: toggle failed — ${failure.message}');
        // Put the heart back the way it was and say why.
        emit(state.copyWith(
          savedIds: wasSaved
              ? ({...state.savedIds}..add(event.itemId))
              : ({...state.savedIds}..remove(event.itemId)),
          status: WishlistStatus.failure,
          message: failure.message,
        ));
      },
      (_) async {
        emit(state.copyWith(
          status: WishlistStatus.success,
          message: wasSaved ? 'Removed from wishlist' : 'Added to wishlist',
        ));
        // Re-sync so the list picks up the full item the server stored.
        add(const LoadWishlistEvent());
      },
    );
  }
}
