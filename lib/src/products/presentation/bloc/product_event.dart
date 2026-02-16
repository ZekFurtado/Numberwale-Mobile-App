part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load products with current filters
class LoadProductsEvent extends ProductEvent {
  final ProductFilters filters;

  const LoadProductsEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

/// Load next page of products (pagination)
class LoadMoreProductsEvent extends ProductEvent {
  const LoadMoreProductsEvent();
}

/// Apply filters and reload products
class ApplyFiltersEvent extends ProductEvent {
  final ProductFilters filters;

  const ApplyFiltersEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

/// Search products by query
class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search and filters
class ClearFiltersEvent extends ProductEvent {
  const ClearFiltersEvent();
}

/// Load discounted products
class LoadDiscountedProductsEvent extends ProductEvent {
  final ProductFilters filters;

  const LoadDiscountedProductsEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

/// Load a specific product by number
class LoadProductByNumberEvent extends ProductEvent {
  final String number;

  const LoadProductByNumberEvent({required this.number});

  @override
  List<Object?> get props => [number];
}
