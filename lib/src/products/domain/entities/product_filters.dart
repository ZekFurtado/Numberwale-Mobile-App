import 'package:equatable/equatable.dart';
import 'package:numberwale/src/products/domain/entities/advanced_search_filters.dart';

/// Filters for product listing API
class ProductFilters extends Equatable {
  final String? search;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? sortPrice; // 'lowToHigh' or 'highToLow'
  final String? readyToPort; // 'rtp' or 'crtp'
  final bool? random;
  final String? seed;

  /// Filters to numbers sourced directly from a telecom operator, allowing
  /// 5-minute activation (see the "5 Mins Activation Numbers" API).
  final bool? isDirectFromOperator;

  /// Filters 5-min-activation numbers to a specific operator home state
  /// (e.g. `Maharashtra`). Only meaningful alongside [isDirectFromOperator].
  final String? operatorState;
  final AdvancedSearchFilters? advanced;
  final int page;
  final int limit;

  /// Only include products added within the last [recentDays] days.
  final int? recentDays;

  /// Raw sort expression passed straight through to the API (e.g. `-createdAt`).
  final String? sort;

  /// Skips the total-count DB query for faster responses. When set, the API
  /// returns `totalCount`/`totalPages` as null (see [ProductResultModel]).
  final bool? skipCount;

  const ProductFilters({
    this.search,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortPrice,
    this.readyToPort,
    this.random,
    this.seed,
    this.isDirectFromOperator,
    this.operatorState,
    this.advanced,
    this.page = 1,
    this.limit = 20,
    this.recentDays,
    this.sort,
    this.skipCount,
  });

  ProductFilters copyWith({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortPrice,
    String? readyToPort,
    bool? random,
    String? seed,
    bool? isDirectFromOperator,
    String? operatorState,
    AdvancedSearchFilters? advanced,
    int? page,
    int? limit,
    int? recentDays,
    String? sort,
    bool? skipCount,
  }) {
    return ProductFilters(
      search: search ?? this.search,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      sortPrice: sortPrice ?? this.sortPrice,
      readyToPort: readyToPort ?? this.readyToPort,
      random: random ?? this.random,
      seed: seed ?? this.seed,
      isDirectFromOperator: isDirectFromOperator ?? this.isDirectFromOperator,
      operatorState: operatorState ?? this.operatorState,
      advanced: advanced ?? this.advanced,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      recentDays: recentDays ?? this.recentDays,
      sort: sort ?? this.sort,
      skipCount: skipCount ?? this.skipCount,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    // The API docs describe `search` as a single JSON-encoded string, but
    // that's not what the live backend parses — verified empirically that
    // it expects bracket-notation params instead (search[globalSearch]=...,
    // search[advanced][startsWith]=...), same convention Express's `qs`
    // parser uses natively.
    if (search != null && search!.isNotEmpty) {
      params['search[globalSearch]'] = search!;
    }
    if (advanced != null && !advanced!.isEmpty) {
      params.addAll(advanced!.toQueryParams());
    }

    if (category != null) params['category'] = category!;
    if (minPrice != null && maxPrice != null) {
      params['priceRange'] = '${minPrice!.toInt()}-${maxPrice!.toInt()}';
    } else if (minPrice != null) {
      params['minPrice'] = minPrice!.toInt().toString();
    } else if (maxPrice != null) {
      params['maxPrice'] = maxPrice!.toInt().toString();
    }
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortPrice != null) params['sortPrice'] = sortPrice!;
    if (readyToPort != null) params['readyToPort'] = readyToPort!;
    if (random == true) params['random'] = 'true';
    if (seed != null) params['seed'] = seed!;
    if (isDirectFromOperator == true) {
      params['isDirectFromOperator'] = 'true';
    }
    if (operatorState != null && operatorState!.isNotEmpty) {
      params['operatorState'] = operatorState!;
    }
    if (recentDays != null) params['recentDays'] = recentDays!.toString();
    if (sort != null) params['sort'] = sort!;
    if (skipCount == true) params['skipCount'] = 'true';
    return params;
  }

  @override
  List<Object?> get props => [
    search,
    category,
    minPrice,
    maxPrice,
    sortBy,
    sortPrice,
    readyToPort,
    random,
    seed,
    isDirectFromOperator,
    operatorState,
    advanced,
    page,
    limit,
    recentDays,
    sort,
    skipCount,
  ];
}
