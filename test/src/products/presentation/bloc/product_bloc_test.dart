import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/domain/entities/advanced_search_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_result.dart';
import 'package:numberwale/src/products/domain/entities/similar_number_filters.dart';
import 'package:numberwale/src/products/domain/usecases/get_discounted_products.dart';
import 'package:numberwale/src/products/domain/usecases/get_product_by_number.dart';
import 'package:numberwale/src/products/domain/usecases/get_products.dart';
import 'package:numberwale/src/products/domain/usecases/get_similar_products.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockGetDiscountedProducts extends Mock implements GetDiscountedProducts {}

class MockGetProductByNumber extends Mock implements GetProductByNumber {}

class MockGetSimilarProducts extends Mock implements GetSimilarProducts {}

PhoneNumber _phone(String id, String number) =>
    PhoneNumber(id: id, number: number, price: 1000, category: 'vip', operator: 'Airtel');

ProductResult _result(List<PhoneNumber> products) => ProductResult(
      products: products,
      totalCount: products.length,
      currentPage: 1,
      totalPages: 1,
      itemsPerPage: 20,
      hasNextPage: false,
      hasPrevPage: false,
    );

void main() {
  late MockGetProducts getProducts;
  late MockGetDiscountedProducts getDiscountedProducts;
  late MockGetProductByNumber getProductByNumber;
  late MockGetSimilarProducts getSimilarProducts;

  setUpAll(() {
    registerFallbackValue(const GetProductsParams(filters: ProductFilters()));
    registerFallbackValue(
      GetSimilarProductsParams(
        filters: SimilarNumberFilters(type: 'prefix2', value: '12'),
      ),
    );
  });

  setUp(() {
    getProducts = MockGetProducts();
    getDiscountedProducts = MockGetDiscountedProducts();
    getProductByNumber = MockGetProductByNumber();
    getSimilarProducts = MockGetSimilarProducts();
  });

  ProductBloc buildBloc() => ProductBloc(
        getProducts: getProducts,
        getDiscountedProducts: getDiscountedProducts,
        getProductByNumber: getProductByNumber,
        getSimilarProducts: getSimilarProducts,
      );

  bool isSuffixCall(GetSimilarProductsParams params) =>
      params.filters.type.startsWith('suffix');
  bool isPrefixCall(GetSimilarProductsParams params) =>
      params.filters.type.startsWith('prefix');

  group('ProductBloc + Similar Number Fetch API', () {
    blocTest<ProductBloc, ProductState>(
      'merges similar prefix/suffix matches into a non-empty exact-match list',
      setUp: () {
        when(() => getProducts(any())).thenAnswer(
          (_) async => Right(_result([_phone('p1', '9800000089')])),
        );
        when(() => getSimilarProducts(any(that: predicate(isPrefixCall))))
            .thenAnswer((_) async => Right(_result([_phone('p2', '9812345678')])));
        when(() => getSimilarProducts(any(that: predicate(isSuffixCall))))
            .thenAnswer((_) async => Right(_result([_phone('p3', '9123456789')])));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const LoadProductsEvent(
          filters: ProductFilters(
            advanced: AdvancedSearchFilters(startsWith: '98', endsWith: '89'),
          ),
        ),
      ),
      expect: () => [
        const ProductLoading(),
        isA<ProductsLoaded>()
            .having((s) => s.products.map((p) => p.id).toSet(), 'product ids',
                {'p1', 'p2', 'p3'})
            .having((s) => s.closestMatches, 'closestMatches', isNull),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'builds two labeled closest-match groups when the exact search is empty',
      setUp: () {
        when(() => getProducts(any())).thenAnswer((_) async => Right(_result(const [])));
        when(() => getSimilarProducts(any(that: predicate(isPrefixCall))))
            .thenAnswer((_) async => Right(_result([_phone('p1', '9812345678')])));
        when(() => getSimilarProducts(any(that: predicate(isSuffixCall))))
            .thenAnswer((_) async => Right(_result([_phone('p2', '9123456789')])));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const LoadProductsEvent(
          filters: ProductFilters(
            advanced: AdvancedSearchFilters(startsWith: '987', endsWith: '789'),
          ),
        ),
      ),
      expect: () => [
        const ProductLoading(),
        isA<ProductsLoaded>()
            .having((s) => s.products, 'products', isEmpty)
            .having(
              (s) => s.closestMatches?.map((g) => g.label).toList(),
              'group labels, in order',
              [
                "Closest Matches (ignoring 'Starts With')",
                "Closest Matches (ignoring 'Ends With')",
              ],
            ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'labels the lone group plainly when only one pattern filter is set',
      setUp: () {
        when(() => getProducts(any())).thenAnswer((_) async => Right(_result(const [])));
        when(() => getSimilarProducts(any(that: predicate(isPrefixCall))))
            .thenAnswer((_) async => Right(_result([_phone('p1', '9812345678')])));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const LoadProductsEvent(
          filters: ProductFilters(
            advanced: AdvancedSearchFilters(startsWith: '987'),
          ),
        ),
      ),
      expect: () => [
        const ProductLoading(),
        isA<ProductsLoaded>()
            .having((s) => s.products, 'products', isEmpty)
            .having(
              (s) => s.closestMatches?.map((g) => g.label).toList(),
              'group labels',
              ['Closest Matches'],
            ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'skips similar-number calls entirely when no pattern filter is set',
      setUp: () {
        when(() => getProducts(any())).thenAnswer(
          (_) async => Right(_result(const [])),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadProductsEvent(filters: ProductFilters())),
      expect: () => [
        const ProductLoading(),
        isA<ProductsLoaded>()
            .having((s) => s.products, 'products', isEmpty)
            .having((s) => s.closestMatches, 'closestMatches', isNull),
      ],
      verify: (_) {
        verifyNever(() => getSimilarProducts(any()));
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits ProductError on failure without touching the similar-number API',
      setUp: () {
        when(() => getProducts(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'boom', statusCode: '500')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const LoadProductsEvent(
          filters: ProductFilters(
            advanced: AdvancedSearchFilters(startsWith: '987'),
          ),
        ),
      ),
      expect: () => [
        const ProductLoading(),
        const ProductError(message: 'boom'),
      ],
      verify: (_) {
        verifyNever(() => getSimilarProducts(any()));
      },
    );
  });
}
