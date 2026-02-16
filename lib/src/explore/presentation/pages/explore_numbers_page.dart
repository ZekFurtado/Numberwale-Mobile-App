import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/models/filter_models.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/filter_bottom_sheet.dart';
import 'package:numberwale/core/widgets/product_list_item.dart';
import 'package:numberwale/core/widgets/sort_bottom_sheet.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

class ExploreNumbersPage extends StatefulWidget {
  const ExploreNumbersPage({super.key});

  @override
  State<ExploreNumbersPage> createState() => _ExploreNumbersPageState();
}

class _ExploreNumbersPageState extends State<ExploreNumbersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  NumberFilters _uiFilters = const NumberFilters();

  @override
  void initState() {
    super.initState();
    // Load products on first view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(const LoadProductsEvent(
            filters: ProductFilters(),
          ));
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<ProductBloc>().state;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state is ProductsLoaded &&
        state.hasNextPage) {
      context.read<ProductBloc>().add(const LoadMoreProductsEvent());
    }
  }

  /// Map local UI filters to the domain ProductFilters for API dispatch.
  ProductFilters _toProductFilters() {
    String? sortPrice;
    if (_uiFilters.sortBy == SortOption.priceLowToHigh) {
      sortPrice = 'lowToHigh';
    } else if (_uiFilters.sortBy == SortOption.priceHighToLow) {
      sortPrice = 'highToLow';
    }

    final category = _uiFilters.category == NumberCategory.all
        ? null
        : _uiFilters.category.label.toLowerCase().replaceAll(' numbers', '').trim();

    final minPrice = _uiFilters.priceRange == PriceRange.all
        ? null
        : _uiFilters.priceRange.min;
    final maxPrice = _uiFilters.priceRange == PriceRange.all
        ? null
        : _uiFilters.priceRange.max;

    return ProductFilters(
      search: _uiFilters.searchQuery.isNotEmpty ? _uiFilters.searchQuery : null,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortPrice: sortPrice,
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await FilterBottomSheet.show(
      context,
      initialFilters: _uiFilters,
    );
    if (result != null) {
      setState(() => _uiFilters = result);
      if (!mounted) return;
      context.read<ProductBloc>().add(
            ApplyFiltersEvent(filters: _toProductFilters()),
          );
    }
  }

  Future<void> _openSortSheet() async {
    final result = await SortBottomSheet.show(
      context,
      currentSort: _uiFilters.sortBy,
    );
    if (result != null) {
      setState(() => _uiFilters = _uiFilters.copyWith(sortBy: result));
      if (!mounted) return;
      context.read<ProductBloc>().add(
            ApplyFiltersEvent(filters: _toProductFilters()),
          );
    }
  }

  void _clearFilters() {
    setState(() {
      _uiFilters = const NumberFilters();
      _searchController.clear();
    });
    context.read<ProductBloc>().add(const ClearFiltersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                                setState(() => _uiFilters = _uiFilters.copyWith(searchQuery: ''));
                                context.read<ProductBloc>().add(const SearchProductsEvent(query: ''));
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() => _uiFilters = _uiFilters.copyWith(searchQuery: value));
                      context.read<ProductBloc>().add(SearchProductsEvent(query: value));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _openFilterSheet,
                  icon: Badge(
                    isLabelVisible: _uiFilters.hasActiveFilters,
                    child: const Icon(Icons.tune),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _uiFilters.hasActiveFilters
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: _uiFilters.hasActiveFilters
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
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

          // Active filter chips
          if (_uiFilters.hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_uiFilters.category != NumberCategory.all)
                    _ActiveFilterChip(
                      label: _uiFilters.category.label,
                      onRemove: () {
                        setState(() => _uiFilters = _uiFilters.copyWith(category: NumberCategory.all));
                        context.read<ProductBloc>().add(ApplyFiltersEvent(filters: _toProductFilters()));
                      },
                    ),
                  if (_uiFilters.priceRange != PriceRange.all)
                    _ActiveFilterChip(
                      label:
                          '₹${(_uiFilters.priceRange.min / 1000).toStringAsFixed(0)}K–₹${(_uiFilters.priceRange.max / 1000).toStringAsFixed(0)}K',
                      onRemove: () {
                        setState(() => _uiFilters = _uiFilters.copyWith(priceRange: PriceRange.all));
                        context.read<ProductBloc>().add(ApplyFiltersEvent(filters: _toProductFilters()));
                      },
                    ),
                  if (_uiFilters.onlyDiscounted)
                    _ActiveFilterChip(
                      label: 'Discounted',
                      onRemove: () {
                        setState(() => _uiFilters = _uiFilters.copyWith(onlyDiscounted: false));
                        context.read<ProductBloc>().add(ApplyFiltersEvent(filters: _toProductFilters()));
                      },
                    ),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // Product list via BLoC
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading || state is ProductInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.read<ProductBloc>().add(
                                const LoadProductsEvent(filters: ProductFilters()),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                List<dynamic> products = [];
                int totalCount = 0;
                bool isLoadingMore = false;

                if (state is ProductsLoaded) {
                  products = state.products;
                  totalCount = state.totalCount;
                } else if (state is ProductLoadingMore) {
                  products = state.currentProducts;
                  isLoadingMore = true;
                }

                if (products.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No Numbers Found',
                    message: 'Try adjusting your filters or search query.',
                    actionLabel: 'Clear Filters',
                    onAction: _clearFilters,
                  );
                }

                return Column(
                  children: [
                    // Results count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$totalCount number${totalCount != 1 ? 's' : ''} found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: products.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= products.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final pn = products[index];
                          return ProductListItem(
                            phoneNumber: pn.number,
                            price: pn.price,
                            category: pn.category,
                            features: List<String>.from(pn.features),
                            discount: pn.discount > 0 ? pn.discount.toDouble() : null,
                            isFeatured: pn.isFeatured,
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.productDetail,
                              arguments: pn.number,
                            ),
                            onAddToCart: () {
                              if (pn.id != null) {
                                context.read<CartBloc>().add(AddToCartEvent(productId: pn.id!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${pn.number} added to cart')),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
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
  const _ActiveFilterChip({required this.label, required this.onRemove});

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
