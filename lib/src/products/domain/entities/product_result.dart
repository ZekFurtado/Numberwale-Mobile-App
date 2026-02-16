import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

/// Paginated product listing result
class ProductResult extends Equatable {
  final List<PhoneNumber> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;
  final String? seed;

  const ProductResult({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.seed,
  });

  const ProductResult.empty()
      : products = const [],
        totalCount = 0,
        currentPage = 1,
        totalPages = 0,
        itemsPerPage = 20,
        hasNextPage = false,
        hasPrevPage = false,
        seed = null;

  @override
  List<Object?> get props => [
        products,
        totalCount,
        currentPage,
        totalPages,
      ];
}
