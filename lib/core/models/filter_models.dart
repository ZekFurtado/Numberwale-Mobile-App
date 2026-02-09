import 'package:equatable/equatable.dart';

/// Enum for sort options
enum SortOption {
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  newest('Newest First'),
  popular('Most Popular'),
  featured('Featured');

  const SortOption(this.label);
  final String label;
}

/// Enum for number categories
enum NumberCategory {
  all('All Numbers'),
  vip('VIP Numbers'),
  fancy('Fancy Numbers'),
  lucky('Lucky Numbers'),
  sequential('Sequential'),
  repeating('Repeating'),
  mirror('Mirror Numbers'),
  premium('Premium');

  const NumberCategory(this.label);
  final String label;
}

/// Price range filter model
class PriceRange extends Equatable {
  const PriceRange({
    required this.min,
    required this.max,
  });

  final double min;
  final double max;

  @override
  List<Object> get props => [min, max];

  PriceRange copyWith({
    double? min,
    double? max,
  }) {
    return PriceRange(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }

  // Predefined price ranges
  static const PriceRange all = PriceRange(min: 0, max: 1000000);
  static const PriceRange under10k = PriceRange(min: 0, max: 10000);
  static const PriceRange range10kTo25k = PriceRange(min: 10000, max: 25000);
  static const PriceRange range25kTo50k = PriceRange(min: 25000, max: 50000);
  static const PriceRange range50kTo100k = PriceRange(min: 50000, max: 100000);
  static const PriceRange above100k = PriceRange(min: 100000, max: 1000000);
}

/// Complete filter model
class NumberFilters extends Equatable {
  const NumberFilters({
    this.category = NumberCategory.all,
    this.priceRange = PriceRange.all,
    this.sortBy = SortOption.featured,
    this.searchQuery = '',
    this.features = const [],
    this.onlyDiscounted = false,
  });

  final NumberCategory category;
  final PriceRange priceRange;
  final SortOption sortBy;
  final String searchQuery;
  final List<String> features; // e.g., ['Easy', 'Memorable', 'Premium']
  final bool onlyDiscounted;

  @override
  List<Object> get props => [
        category,
        priceRange,
        sortBy,
        searchQuery,
        features,
        onlyDiscounted,
      ];

  NumberFilters copyWith({
    NumberCategory? category,
    PriceRange? priceRange,
    SortOption? sortBy,
    String? searchQuery,
    List<String>? features,
    bool? onlyDiscounted,
  }) {
    return NumberFilters(
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      features: features ?? this.features,
      onlyDiscounted: onlyDiscounted ?? this.onlyDiscounted,
    );
  }

  // Check if any filters are active (excluding default values)
  bool get hasActiveFilters {
    return category != NumberCategory.all ||
        priceRange != PriceRange.all ||
        features.isNotEmpty ||
        onlyDiscounted ||
        searchQuery.isNotEmpty;
  }

  // Reset to default filters
  NumberFilters reset() {
    return const NumberFilters();
  }
}
