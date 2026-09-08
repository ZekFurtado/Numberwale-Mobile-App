import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

/// A "Corporate Elite Pack" (Jodi) - a group of identical/sequential/similar
/// phone numbers sold together, e.g. for a business team.
class CorporatePack extends Equatable {
  final String id;

  /// How the numbers in [products] relate to each other:
  /// 'Series', 'All', 'Prefix', 'Suffix', or 'Both Ends'.
  final String type;

  /// The shared digit pattern the pack is built around.
  final String value;

  final List<PhoneNumber> products;
  final DateTime? createdAt;

  const CorporatePack({
    required this.id,
    required this.type,
    required this.value,
    required this.products,
    this.createdAt,
  });

  int get packSize => products.length;

  double get totalValue =>
      products.fold(0.0, (sum, p) => sum + p.discountedPrice);

  @override
  List<Object?> get props => [id, type, value, products];
}
