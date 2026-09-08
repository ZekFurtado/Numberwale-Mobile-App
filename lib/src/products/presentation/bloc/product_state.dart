part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoadingMore extends ProductState {
  final List<PhoneNumber> currentProducts;
  final ProductFilters currentFilters;

  const ProductLoadingMore({
    required this.currentProducts,
    required this.currentFilters,
  });

  @override
  List<Object?> get props => [currentProducts, currentFilters];
}

class ProductsLoaded extends ProductState {
  final List<PhoneNumber> products;
  final ProductFilters appliedFilters;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  /// Populated only when [products] came back empty for an advanced search
  /// using "Starts With"/"Ends With" — each group relaxes one of those
  /// filters (via the Similar Number Fetch API) to surface close
  /// alternatives instead of a flat "no results" screen.
  final List<ClosestMatchGroup>? closestMatches;

  const ProductsLoaded({
    required this.products,
    required this.appliedFilters,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    this.closestMatches,
  });

  @override
  List<Object?> get props => [
        products,
        appliedFilters,
        totalCount,
        currentPage,
        totalPages,
        hasNextPage,
        closestMatches,
      ];
}

/// One "relax a single pattern filter" suggestion group shown when an
/// advanced Starts With/Ends With search returns zero exact matches.
class ClosestMatchGroup extends Equatable {
  final String label;
  final List<PhoneNumber> products;

  const ClosestMatchGroup({required this.label, required this.products});

  @override
  List<Object?> get props => [label, products];
}

class ProductDetailLoaded extends ProductState {
  final PhoneNumber product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
