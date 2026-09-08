import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/domain/entities/advanced_search_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/entities/similar_number_filters.dart';
import 'package:numberwale/src/products/domain/usecases/get_discounted_products.dart';
import 'package:numberwale/src/products/domain/usecases/get_product_by_number.dart';
import 'package:numberwale/src/products/domain/usecases/get_products.dart';
import 'package:numberwale/src/products/domain/usecases/get_similar_products.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final GetDiscountedProducts _getDiscountedProducts;
  final GetProductByNumber _getProductByNumber;
  final GetSimilarProducts _getSimilarProducts;

  // Track current state for pagination
  List<PhoneNumber> _currentProducts = [];
  ProductFilters _currentFilters = const ProductFilters();
  int _currentPage = 1;
  bool _hasNextPage = false;

  ProductBloc({
    required GetProducts getProducts,
    required GetDiscountedProducts getDiscountedProducts,
    required GetProductByNumber getProductByNumber,
    required GetSimilarProducts getSimilarProducts,
  })  : _getProducts = getProducts,
        _getDiscountedProducts = getDiscountedProducts,
        _getProductByNumber = getProductByNumber,
        _getSimilarProducts = getSimilarProducts,
        super(const ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadMoreProductsEvent>(_onLoadMoreProducts);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<SearchProductsEvent>(_onSearchProducts);
    on<ClearFiltersEvent>(_onClearFilters);
    on<LoadDiscountedProductsEvent>(_onLoadDiscountedProducts);
    on<LoadProductByNumberEvent>(_onLoadProductByNumber);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    _currentFilters = event.filters;
    _currentPage = 1;

    final result = await _getProducts(GetProductsParams(filters: event.filters));

    // dartz's Either.fold forces both branches to return the same type, so
    // an async success branch would force the failure branch to also return
    // a Future — extracting the success value first keeps both emit() calls
    // as plain, sequential statements.
    ProductResult? productResult;
    String? errorMessage;
    result.fold(
      (failure) => errorMessage = failure.message,
      (data) => productResult = data,
    );

    final loadedResult = productResult;
    if (loadedResult == null) {
      emit(ProductError(message: errorMessage ?? 'Failed to load products'));
      return;
    }

    _currentProducts = loadedResult.products;
    _currentPage = loadedResult.currentPage;
    _hasNextPage = loadedResult.hasNextPage;

    final advanced = event.filters.advanced;
    List<ClosestMatchGroup>? closestMatches;

    if (advanced != null && _hasPatternFilter(advanced)) {
      if (_currentProducts.isNotEmpty) {
        _currentProducts = await _mergeSimilarMatches(
          _currentProducts,
          advanced,
          event.filters.category,
        );
      } else {
        closestMatches = await _buildClosestMatchGroups(
          advanced,
          event.filters.category,
        );
      }
    }

    emit(ProductsLoaded(
      products: _currentProducts,
      appliedFilters: _currentFilters,
      totalCount: loadedResult.totalCount,
      currentPage: _currentPage,
      totalPages: loadedResult.totalPages,
      hasNextPage: _hasNextPage,
      closestMatches: closestMatches,
    ));
  }

  bool _hasPatternFilter(AdvancedSearchFilters advanced) {
    return (advanced.startsWith?.isNotEmpty ?? false) ||
        (advanced.endsWith?.isNotEmpty ?? false);
  }

  String _dedupeKey(PhoneNumber product) => product.id ?? product.number;

  /// Appends Similar Number Fetch API results (matching "Starts With"/"Ends
  /// With") to an already non-empty exact-match list, skipping numbers
  /// already present.
  Future<List<PhoneNumber>> _mergeSimilarMatches(
    List<PhoneNumber> primary,
    AdvancedSearchFilters advanced,
    String? category,
  ) async {
    final seen = primary.map(_dedupeKey).toSet();
    final merged = [...primary];

    final queries = [
      SimilarNumberFilters.prefixOf(advanced.startsWith, category: category),
      SimilarNumberFilters.suffixOf(advanced.endsWith, category: category),
    ].whereType<SimilarNumberFilters>();

    for (final query in queries) {
      final result = await _getSimilarProducts(
        GetSimilarProductsParams(filters: query),
      );
      result.fold((_) {}, (similarResult) {
        for (final product in similarResult.products) {
          if (seen.add(_dedupeKey(product))) merged.add(product);
        }
      });
    }

    return merged;
  }

  /// Builds "closest match" suggestion groups for when the exact advanced
  /// search returns zero products: each group relaxes one of "Starts
  /// With"/"Ends With" while keeping the other, via the Similar Number
  /// Fetch API. Order matches the "ignoring Starts With" then "ignoring
  /// Ends With" convention used on the web.
  Future<List<ClosestMatchGroup>> _buildClosestMatchGroups(
    AdvancedSearchFilters advanced,
    String? category,
  ) async {
    final hasStartsWith = advanced.startsWith?.isNotEmpty ?? false;
    final hasEndsWith = advanced.endsWith?.isNotEmpty ?? false;
    final groups = <ClosestMatchGroup>[];

    if (hasEndsWith) {
      final query = SimilarNumberFilters.suffixOf(
        advanced.endsWith,
        category: category,
      );
      if (query != null) {
        final result = await _getSimilarProducts(
          GetSimilarProductsParams(filters: query),
        );
        result.fold((_) {}, (similarResult) {
          if (similarResult.products.isNotEmpty) {
            groups.add(ClosestMatchGroup(
              label: hasStartsWith
                  ? "Closest Matches (ignoring 'Starts With')"
                  : 'Closest Matches',
              products: similarResult.products,
            ));
          }
        });
      }
    }

    if (hasStartsWith) {
      final query = SimilarNumberFilters.prefixOf(
        advanced.startsWith,
        category: category,
      );
      if (query != null) {
        final result = await _getSimilarProducts(
          GetSimilarProductsParams(filters: query),
        );
        result.fold((_) {}, (similarResult) {
          if (similarResult.products.isNotEmpty) {
            groups.add(ClosestMatchGroup(
              label: hasEndsWith
                  ? "Closest Matches (ignoring 'Ends With')"
                  : 'Closest Matches',
              products: similarResult.products,
            ));
          }
        });
      }
    }

    return groups;
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (!_hasNextPage) return;

    emit(ProductLoadingMore(
      currentProducts: _currentProducts,
      currentFilters: _currentFilters,
    ));

    final nextPage = _currentPage + 1;
    final nextFilters = _currentFilters.copyWith(page: nextPage);

    final result = await _getProducts(GetProductsParams(filters: nextFilters));

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (productResult) {
        _currentProducts = [..._currentProducts, ...productResult.products];
        _currentPage = productResult.currentPage;
        _hasNextPage = productResult.hasNextPage;
        emit(ProductsLoaded(
          products: _currentProducts,
          appliedFilters: _currentFilters,
          totalCount: productResult.totalCount,
          currentPage: _currentPage,
          totalPages: productResult.totalPages,
          hasNextPage: _hasNextPage,
        ));
      },
    );
  }

  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<ProductState> emit,
  ) async {
    add(LoadProductsEvent(filters: event.filters.copyWith(page: 1)));
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    final filters = _currentFilters.copyWith(
      search: event.query,
      page: 1,
    );
    add(LoadProductsEvent(filters: filters));
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<ProductState> emit,
  ) async {
    add(const LoadProductsEvent(filters: ProductFilters()));
  }

  Future<void> _onLoadDiscountedProducts(
    LoadDiscountedProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    _currentFilters = event.filters;
    _currentPage = 1;

    final result = await _getDiscountedProducts(
      GetDiscountedProductsParams(filters: event.filters),
    );

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (productResult) {
        _currentProducts = productResult.products;
        _currentPage = productResult.currentPage;
        _hasNextPage = productResult.hasNextPage;
        emit(ProductsLoaded(
          products: _currentProducts,
          appliedFilters: _currentFilters,
          totalCount: productResult.totalCount,
          currentPage: _currentPage,
          totalPages: productResult.totalPages,
          hasNextPage: _hasNextPage,
        ));
      },
    );
  }

  Future<void> _onLoadProductByNumber(
    LoadProductByNumberEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _getProductByNumber(
      GetProductByNumberParams(number: event.number),
    );

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }
}
