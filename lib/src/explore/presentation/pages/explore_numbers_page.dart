import 'package:flutter/material.dart';
import 'package:numberwale/core/models/filter_models.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/category_filter_chip.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/filter_bottom_sheet.dart';
import 'package:numberwale/core/widgets/product_list_item.dart';
import 'package:numberwale/core/widgets/sort_bottom_sheet.dart';

class ExploreNumbersPage extends StatefulWidget {
  const ExploreNumbersPage({super.key});

  @override
  State<ExploreNumbersPage> createState() => _ExploreNumbersPageState();
}

class _ExploreNumbersPageState extends State<ExploreNumbersPage> {
  final TextEditingController _searchController = TextEditingController();
  NumberFilters _filters = const NumberFilters();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mock data - will be replaced with actual API calls
  List<Map<String, dynamic>> _getMockNumbers() {
    return [
      {
        'number': '9876543210',
        'price': 25000.0,
        'category': 'VIP',
        'features': ['Sequential', 'Premium'],
        'discount': 10.0,
        'isFeatured': true,
      },
      {
        'number': '9999999999',
        'price': 50000.0,
        'category': 'Premium VIP',
        'features': ['All 9s', 'Unique'],
        'discount': null,
        'isFeatured': true,
      },
      {
        'number': '9876000000',
        'price': 15000.0,
        'category': 'Fancy',
        'features': ['Pattern', 'Memorable'],
        'discount': 15.0,
        'isFeatured': false,
      },
      {
        'number': '9811111111',
        'price': 35000.0,
        'category': 'VIP',
        'features': ['Repeating', 'Premium'],
        'discount': 5.0,
        'isFeatured': false,
      },
      {
        'number': '9123456789',
        'price': 12000.0,
        'category': 'Sequential',
        'features': ['Easy', 'Memorable'],
        'discount': null,
        'isFeatured': false,
      },
      {
        'number': '9898989898',
        'price': 28000.0,
        'category': 'Mirror',
        'features': ['Mirror', 'Unique'],
        'discount': 8.0,
        'isFeatured': true,
      },
      {
        'number': '9777777777',
        'price': 45000.0,
        'category': 'Lucky',
        'features': ['Lucky 7', 'Premium'],
        'discount': null,
        'isFeatured': false,
      },
      {
        'number': '9100000001',
        'price': 20000.0,
        'category': 'Fancy',
        'features': ['Unique', 'Memorable'],
        'discount': 12.0,
        'isFeatured': false,
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredNumbers() {
    var numbers = _getMockNumbers();

    // Apply search filter
    if (_filters.searchQuery.isNotEmpty) {
      numbers = numbers.where((num) {
        return num['number'].toString().contains(_filters.searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_filters.category != NumberCategory.all) {
      numbers = numbers.where((num) {
        return num['category']
            .toString()
            .toLowerCase()
            .contains(_filters.category.label.toLowerCase());
      }).toList();
    }

    // Apply price range filter
    numbers = numbers.where((num) {
      final price = num['price'] as double;
      return price >= _filters.priceRange.min &&
          price <= _filters.priceRange.max;
    }).toList();

    // Apply discount filter
    if (_filters.onlyDiscounted) {
      numbers = numbers.where((num) {
        return num['discount'] != null && num['discount'] > 0;
      }).toList();
    }

    // Apply sorting
    switch (_filters.sortBy) {
      case SortOption.priceLowToHigh:
        numbers.sort((a, b) => (a['price'] as double).compareTo(b['price']));
        break;
      case SortOption.priceHighToLow:
        numbers.sort((a, b) => (b['price'] as double).compareTo(a['price']));
        break;
      case SortOption.featured:
        numbers.sort((a, b) {
          final aFeatured = a['isFeatured'] as bool;
          final bFeatured = b['isFeatured'] as bool;
          if (aFeatured == bFeatured) return 0;
          return aFeatured ? -1 : 1;
        });
        break;
      default:
        // Keep default order for newest and popular
        break;
    }

    return numbers;
  }

  Future<void> _openFilterSheet() async {
    final result = await FilterBottomSheet.show(
      context,
      initialFilters: _filters,
    );

    if (result != null) {
      setState(() {
        _filters = result;
      });
    }
  }

  Future<void> _openSortSheet() async {
    final result = await SortBottomSheet.show(
      context,
      currentSort: _filters.sortBy,
    );

    if (result != null) {
      setState(() {
        _filters = _filters.copyWith(sortBy: result);
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filters = _filters.reset();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredNumbers = _getFilteredNumbers();

    return Scaffold(
      body: Column(
        children: [
          // Search bar with filter and sort buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search numbers...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filters = _filters.copyWith(searchQuery: '');
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(searchQuery: value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Filter button
                IconButton.filled(
                  onPressed: _openFilterSheet,
                  icon: Badge(
                    isLabelVisible: _filters.hasActiveFilters,
                    child: const Icon(Icons.tune),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _filters.hasActiveFilters
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: _filters.hasActiveFilters
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),

                // Sort button
                IconButton.filled(
                  onPressed: _openSortSheet,
                  icon: const Icon(Icons.sort),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Active filters chips
          if (_filters.hasActiveFilters) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_filters.category != NumberCategory.all)
                    _ActiveFilterChip(
                      label: _filters.category.label,
                      onRemove: () {
                        setState(() {
                          _filters = _filters.copyWith(
                            category: NumberCategory.all,
                          );
                        });
                      },
                    ),
                  if (_filters.priceRange != PriceRange.all)
                    _ActiveFilterChip(
                      label:
                          '₹${(_filters.priceRange.min / 1000).toStringAsFixed(0)}K - ₹${(_filters.priceRange.max / 1000).toStringAsFixed(0)}K',
                      onRemove: () {
                        setState(() {
                          _filters = _filters.copyWith(
                            priceRange: PriceRange.all,
                          );
                        });
                      },
                    ),
                  if (_filters.onlyDiscounted)
                    _ActiveFilterChip(
                      label: 'Discounted',
                      onRemove: () {
                        setState(() {
                          _filters = _filters.copyWith(onlyDiscounted: false);
                        });
                      },
                    ),
                  ..._filters.features.map((feature) {
                    return _ActiveFilterChip(
                      label: feature,
                      onRemove: () {
                        setState(() {
                          final features = List<String>.from(_filters.features);
                          features.remove(feature);
                          _filters = _filters.copyWith(features: features);
                        });
                      },
                    );
                  }),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Results count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '${filteredNumbers.length} number${filteredNumbers.length != 1 ? 's' : ''} found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Product list
          Expanded(
            child: filteredNumbers.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No Numbers Found',
                    message:
                        'Try adjusting your filters or search query to find more numbers.',
                    actionLabel: 'Clear Filters',
                    onAction: _clearFilters,
                  )
                : ListView.builder(
                    itemCount: filteredNumbers.length,
                    itemBuilder: (context, index) {
                      final number = filteredNumbers[index];
                      return ProductListItem(
                        phoneNumber: number['number'],
                        price: number['price'],
                        category: number['category'],
                        features: List<String>.from(number['features']),
                        discount: number['discount'],
                        isFeatured: number['isFeatured'],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.productDetail,
                            arguments: number['number'],
                          );
                        },
                        onAddToCart: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Added ${number['number']} to cart!'),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
      ),
      deleteIconColor: theme.colorScheme.onPrimaryContainer,
    );
  }
}
