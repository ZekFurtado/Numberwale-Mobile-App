import 'package:flutter_test/flutter_test.dart';
import 'package:numberwale/src/products/domain/entities/similar_number_filters.dart';

void main() {
  group('SimilarNumberFilters.prefixOf', () {
    test('returns null when fewer than 2 digits are given', () {
      expect(SimilarNumberFilters.prefixOf('9'), isNull);
      expect(SimilarNumberFilters.prefixOf(''), isNull);
      expect(SimilarNumberFilters.prefixOf(null), isNull);
    });

    test('builds prefixN using the full digit count when 2-5', () {
      final filters = SimilarNumberFilters.prefixOf('786');
      expect(filters!.type, 'prefix3');
      expect(filters.value, '786');
    });

    test('clamps to the first 5 digits and prefix5 when longer', () {
      final filters = SimilarNumberFilters.prefixOf('9876543');
      expect(filters!.type, 'prefix5');
      expect(filters.value, '98765');
    });

    test('strips non-digit characters before counting', () {
      final filters = SimilarNumberFilters.prefixOf('98-76');
      expect(filters!.type, 'prefix4');
      expect(filters.value, '9876');
    });
  });

  group('SimilarNumberFilters.suffixOf', () {
    test('returns null when fewer than 2 digits are given', () {
      expect(SimilarNumberFilters.suffixOf('7'), isNull);
    });

    test('builds suffixN anchored to the end of the digits', () {
      final filters = SimilarNumberFilters.suffixOf('789');
      expect(filters!.type, 'suffix3');
      expect(filters.value, '789');
    });

    test('clamps to the last 5 digits and suffix5 when longer', () {
      final filters = SimilarNumberFilters.suffixOf('1234567');
      expect(filters!.type, 'suffix5');
      expect(filters.value, '34567');
    });
  });

  group('SimilarNumberFilters.toQueryParams', () {
    test('includes type, value, page, and limit', () {
      const filters = SimilarNumberFilters(type: 'suffix3', value: '786');
      expect(filters.toQueryParams(), {
        'type': 'suffix3',
        'value': '786',
        'page': '1',
        'limit': '20',
      });
    });

    test('includes category only when set', () {
      const filters = SimilarNumberFilters(
        type: 'prefix2',
        value: '98',
        category: '786-numbers',
      );
      expect(filters.toQueryParams()['category'], '786-numbers');
    });
  });
}
