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

  const ProductsLoaded({
    required this.products,
    required this.appliedFilters,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [
        products,
        appliedFilters,
        totalCount,
        currentPage,
        totalPages,
        hasNextPage,
      ];
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
