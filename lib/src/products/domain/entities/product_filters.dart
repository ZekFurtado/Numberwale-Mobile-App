import 'package:equatable/equatable.dart';

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
  final int page;
  final int limit;

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
    this.page = 1,
    this.limit = 20,
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
    int? page,
    int? limit,
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
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    if (category != null) params['category'] = category!;
    if (minPrice != null) params['minPrice'] = minPrice!.toInt().toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice!.toInt().toString();
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortPrice != null) params['sortPrice'] = sortPrice!;
    if (readyToPort != null) params['readyToPort'] = readyToPort!;
    if (random == true) params['random'] = 'true';
    if (seed != null) params['seed'] = seed!;
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
        page,
        limit,
      ];
}
