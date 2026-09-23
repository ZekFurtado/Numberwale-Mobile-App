import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

/// What kind of thing a wishlist row points at. The backend keys adds and
/// removes off this, and packs additionally need their size.
enum WishlistItemType { product, pack }

extension WishlistItemTypeX on WishlistItemType {
  /// The wire value the API uses (`itemType`).
  String get apiValue => this == WishlistItemType.pack ? 'pack' : 'product';

  static WishlistItemType fromApi(String? value) =>
      value == 'pack' ? WishlistItemType.pack : WishlistItemType.product;
}

/// A single saved entry: either one phone number, or a Corporate Elite Pack
/// with all of its numbers.
class WishlistItem extends Equatable {
  const WishlistItem({
    required this.id,
    required this.type,
    required this.numbers,
    this.packType,
    this.packValue,
  });

  /// The product's or pack's `_id` — the handle used to add and remove.
  final String id;

  final WishlistItemType type;

  /// One entry for a product, all of the pack's numbers for a pack.
  final List<PhoneNumber> numbers;

  /// How a pack's numbers relate ('Series', 'Prefix', …). Null for products.
  final String? packType;

  /// The shared digit pattern a pack is built around. Null for products.
  final String? packValue;

  bool get isPack => type == WishlistItemType.pack;

  /// Pack size, which the remove endpoint needs to disambiguate packs.
  int? get packSize => isPack ? numbers.length : null;

  double get totalPrice =>
      numbers.fold(0.0, (sum, n) => sum + n.discountedPrice);

  @override
  List<Object?> get props => [id, type, numbers.length];
}
