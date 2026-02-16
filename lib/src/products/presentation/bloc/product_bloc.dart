import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/usecases/get_discounted_products.dart';
import 'package:numberwale/src/products/domain/usecases/get_product_by_number.dart';
import 'package:numberwale/src/products/domain/usecases/get_products.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts _getProducts;
  final GetDiscountedProducts _getDiscountedProducts;
  final GetProductByNumber _getProductByNumber;

  // Track current state for pagination
  List<PhoneNumber> _currentProducts = [];
  ProductFilters _currentFilters = const ProductFilters();
  int _currentPage = 1;
  bool _hasNextPage = false;

  ProductBloc({
    required GetProducts getProducts,
    required GetDiscountedProducts getDiscountedProducts,
    required GetProductByNumber getProductByNumber,
  })  : _getProducts = getProducts,
        _getDiscountedProducts = getDiscountedProducts,
        _getProductByNumber = getProductByNumber,
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
