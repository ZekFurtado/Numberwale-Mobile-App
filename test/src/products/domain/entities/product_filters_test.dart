import 'package:flutter_test/flutter_test.dart';
import 'package:numberwale/src/products/domain/entities/advanced_search_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';

void main() {
  group('AdvancedSearchFilters.toQueryParams', () {
    test('omits null and empty fields', () {
      const filters = AdvancedSearchFilters();
      expect(filters.toQueryParams(), isEmpty);
      expect(filters.isEmpty, isTrue);
    });

    test('includes only populated fields under search[advanced][...]', () {
      const filters = AdvancedSearchFilters(startsWith: '98', literSum: 45);
      expect(filters.toQueryParams(), {
        'search[advanced][startsWith]': '98',
        'search[advanced][literSum]': '45',
      });
    });

    test('truncates mustContain/notContain to 5 comma-separated digits', () {
      const filters = AdvancedSearchFilters(mustContain: '1,2,3,4,5,6,7');
      expect(filters.toQueryParams()['search[advanced][mustContain]'], '1,2,3,4,5');
    });

    test('only emits mostContain when both digit and count are set', () {
      const digitOnly = AdvancedSearchFilters(mostContainDigit: '9');
      expect(digitOnly.toQueryParams().containsKey('search[advanced][mostContain][digit]'), isFalse);

      const both = AdvancedSearchFilters(mostContainDigit: '9', mostContainCount: 3);
      expect(both.toQueryParams(), {
        'search[advanced][mostContain][digit]': '9',
        'search[advanced][mostContain][count]': '3',
      });
    });

    test('only emits exactDigitPlacement when exactly 10 chars', () {
      const short = AdvancedSearchFilters(exactDigitPlacement: '98???');
      expect(short.toQueryParams().containsKey('search[advanced][exactDigitPlacement]'), isFalse);

      const full = AdvancedSearchFilters(exactDigitPlacement: '98?????789');
      expect(full.toQueryParams()['search[advanced][exactDigitPlacement]'], '98?????789');
    });
  });

  group('AdvancedSearchFilters.clearing', () {
    test('nulls out only the requested field(s), keeping the rest', () {
      const filters = AdvancedSearchFilters(
        startsWith: '987',
        anywhere: '123',
        endsWith: '789',
        literSum: 45,
      );

      final withoutStartsWith = filters.clearing(startsWith: true);
      expect(withoutStartsWith.startsWith, isNull);
      expect(withoutStartsWith.anywhere, '123');
      expect(withoutStartsWith.endsWith, '789');
      expect(withoutStartsWith.literSum, 45);

      final withoutBoth = filters.clearing(startsWith: true, endsWith: true);
      expect(withoutBoth.startsWith, isNull);
      expect(withoutBoth.endsWith, isNull);
      expect(withoutBoth.anywhere, '123');
    });
  });

  group('ProductFilters.toQueryParams', () {
    test('omits search params when no search/advanced filters set', () {
      const filters = ProductFilters();
      final params = filters.toQueryParams();
      expect(params.keys.where((k) => k.startsWith('search')), isEmpty);
    });

    test('emits search[globalSearch] for the basic search box', () {
      const filters = ProductFilters(search: '98');
      expect(filters.toQueryParams()['search[globalSearch]'], '98');
    });

    test('combines search[globalSearch] with search[advanced][...] params', () {
      const filters = ProductFilters(
        search: '98',
        advanced: AdvancedSearchFilters(startsWith: '98', mustContain: '7,9'),
      );
      final params = filters.toQueryParams();
      expect(params['search[globalSearch]'], '98');
      expect(params['search[advanced][startsWith]'], '98');
      expect(params['search[advanced][mustContain]'], '7,9');
    });

    test('leaves priceRange/category/sortPrice as unchanged top-level params', () {
      const filters = ProductFilters(
        category: 'vip',
        minPrice: 1000,
        maxPrice: 10000,
        sortPrice: 'lowToHigh',
      );
      final params = filters.toQueryParams();
      expect(params['category'], 'vip');
      expect(params['priceRange'], '1000-10000');
      expect(params['sortPrice'], 'lowToHigh');
    });
  });
}
