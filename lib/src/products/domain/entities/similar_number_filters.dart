import 'package:equatable/equatable.dart';

/// Filters for the "Similar Number Fetch" API
/// (`GET /api/v1/products/similar`), used to find numbers that share a
/// prefix or suffix pattern with a given digit sequence.
class SimilarNumberFilters extends Equatable {
  /// e.g. `prefix3`, `suffix2`, `both4`.
  final String type;

  /// The digit pattern to match (e.g. `786`).
  final String value;

  /// Optional category slug to narrow down similar numbers.
  final String? category;

  final int page;
  final int limit;

  const SimilarNumberFilters({
    required this.type,
    required this.value,
    this.category,
    this.page = 1,
    this.limit = 20,
  });

  /// Builds a `prefixN` query from "Starts With" digits, where N is clamped
  /// to the API's supported range of 2-5. Returns null when there aren't
  /// enough digits (minimum 2) to form a valid pattern.
  static SimilarNumberFilters? prefixOf(
    String? startsWith, {
    String? category,
    int page = 1,
    int limit = 20,
  }) {
    final digits = _digitsOnly(startsWith);
    if (digits.length < 2) return null;
    final len = digits.length > 5 ? 5 : digits.length;
    return SimilarNumberFilters(
      type: 'prefix$len',
      value: digits.substring(0, len),
      category: category,
      page: page,
      limit: limit,
    );
  }

  /// Builds a `suffixN` query from "Ends With" digits, anchored to the end
  /// of the string. Same clamping rules as [prefixOf].
  static SimilarNumberFilters? suffixOf(
    String? endsWith, {
    String? category,
    int page = 1,
    int limit = 20,
  }) {
    final digits = _digitsOnly(endsWith);
    if (digits.length < 2) return null;
    final len = digits.length > 5 ? 5 : digits.length;
    return SimilarNumberFilters(
      type: 'suffix$len',
      value: digits.substring(digits.length - len),
      category: category,
      page: page,
      limit: limit,
    );
  }

  static String _digitsOnly(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'\D'), '');
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'type': type,
      'value': value,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category!.isNotEmpty) {
      params['category'] = category!;
    }
    return params;
  }

  @override
  List<Object?> get props => [type, value, category, page, limit];
}
