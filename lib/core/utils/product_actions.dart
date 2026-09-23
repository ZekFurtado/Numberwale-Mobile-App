import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';
import 'package:numberwale/src/wishlist/presentation/bloc/wishlist_bloc.dart';

/// The one place the app decides what a card's cart / buy / enquire / heart
/// buttons actually do, so every list of numbers behaves the same way.
class ProductActions {
  const ProductActions._();

  /// Numbers whose GST-inclusive price clears ₹5,00,000 aren't sold online —
  /// they get an "Enquire Now" button instead of "Buy Now". Mirrors the rule
  /// the website applies (`finalPrice + 18% > 5e5`).
  static const int enquiryThreshold = 500000;

  static bool isEnquiryOnly(double price) => price * 1.18 > enquiryThreshold;

  /// Adds [product] to the server cart. Confirmation and errors are surfaced
  /// by the app-level listener in `main.dart`.
  static void addToCart(BuildContext context, PhoneNumber product) {
    final productId = product.id;
    if (productId == null || productId.isEmpty) {
      _warn(context, 'This number can\'t be added to the cart right now.');
      return;
    }
    context.read<CartBloc>().add(AddToCartEvent(productId: productId));
  }

  /// Adds [product] to the cart and continues to the cart page once the
  /// server confirms — the same thing the website's "Buy Now" does.
  static void buyNow(BuildContext context, PhoneNumber product) {
    final productId = product.id;
    if (productId == null || productId.isEmpty) {
      _warn(context, 'This number can\'t be purchased right now.');
      return;
    }
    context
        .read<CartBloc>()
        .add(AddToCartEvent(productId: productId, buyNow: true));
  }

  /// Opens the custom-number request form pre-filled with this number.
  static void enquire(BuildContext context, PhoneNumber product) {
    Navigator.pushNamed(
      context,
      Routes.customRequest,
      arguments: product.number,
    );
  }

  /// "Buy Now" for numbers under the threshold, "Enquire Now" above it.
  static void buyOrEnquire(BuildContext context, PhoneNumber product) {
    if (isEnquiryOnly(product.discountedPrice)) {
      enquire(context, product);
    } else {
      buyNow(context, product);
    }
  }

  static void toggleWishlist(BuildContext context, PhoneNumber product) {
    final productId = product.id;
    if (productId == null || productId.isEmpty) {
      _warn(context, 'This number can\'t be saved right now.');
      return;
    }
    context.read<WishlistBloc>().add(ToggleWishlistEvent(itemId: productId));
  }

  static void _warn(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Reads whether [productId] is currently in the wishlist. Rebuilds the
/// calling widget when that changes.
///
/// IMPORTANT: never call this with the `context` argument a
/// `ListView.builder`/`GridView.builder`/`SliverChildBuilderDelegate`
/// `itemBuilder` hands you — that context belongs to the sliver's shared
/// item slot, not to your widget, and `context.select` asserts loudly
/// against being used there (it would silently rebuild the *entire*
/// list on every wishlist change instead of just one row). Use
/// [WishlistAware] to get a context that's safe to select from inside a
/// builder callback.
bool watchIsWishlisted(BuildContext context, String? productId) {
  if (productId == null) return false;
  return context
      .select<WishlistBloc, bool>((bloc) => bloc.state.isSaved(productId));
}

/// Gives [builder] a fresh, item-scoped [BuildContext] to call
/// [watchIsWishlisted] from.
///
/// Use this to wrap a card built inside a `ListView.builder` /
/// `GridView.builder` / `SliverChildBuilderDelegate` `itemBuilder` — that
/// callback's own `context` parameter is shared sliver plumbing, not a
/// per-item context, so calling `context.select` directly on it either
/// throws (Provider's Sliver-safety assertion) or, if it didn't, would
/// rebuild the whole list on every wishlist change. `WishlistAware` is
/// itself a normal widget instantiated per item, so its `build` method
/// receives a proper descendant context that's safe to select from and
/// only rebuilds that one row.
///
/// ```dart
/// itemBuilder: (context, index) => WishlistAware(
///   itemId: products[index].id,
///   builder: (context, isWishlisted) => ProductCard(
///     ...,
///     isWishlisted: isWishlisted,
///     onWishlist: () => ProductActions.toggleWishlist(context, products[index]),
///   ),
/// ),
/// ```
class WishlistAware extends StatelessWidget {
  const WishlistAware({super.key, required this.itemId, required this.builder});

  final String? itemId;
  final Widget Function(BuildContext context, bool isWishlisted) builder;

  @override
  Widget build(BuildContext context) =>
      builder(context, watchIsWishlisted(context, itemId));
}

/// Same, for a Corporate Elite Pack.
bool watchIsPackWishlisted(BuildContext context, String? packId) =>
    watchIsWishlisted(context, packId);

/// Toggles a whole Corporate Elite Pack.
void togglePackWishlist(BuildContext context, String packId, int packSize) {
  context.read<WishlistBloc>().add(ToggleWishlistEvent(
        itemId: packId,
        type: WishlistItemType.pack,
        packSize: packSize,
      ));
}
