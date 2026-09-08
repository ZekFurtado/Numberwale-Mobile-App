import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/models/filter_models.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/filter_bottom_sheet.dart';
import 'package:numberwale/core/widgets/product_card.dart';
import 'package:numberwale/core/widgets/sort_bottom_sheet.dart';
import 'package:numberwale/src/ai_search/domain/entities/ai_search_filters.dart';
import 'package:numberwale/src/ai_search/presentation/bloc/ai_search_bloc.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/products/domain/entities/advanced_search_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

enum _SearchMode { aiSearch, globalSearch }

class ExploreNumbersPage extends StatefulWidget {
  const ExploreNumbersPage({super.key});

  @override
  State<ExploreNumbersPage> createState() => _ExploreNumbersPageState();
}

class _ExploreNumbersPageState extends State<ExploreNumbersPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _aiSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  NumberFilters _uiFilters = const NumberFilters();
  _SearchMode _mode = _SearchMode.aiSearch;
  Timer? _searchDebounce;
  Timer? _aiSearchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = context.read<AppNavigationCubit>().state;
      final pendingQuery = navState.initialSearchQuery;
      final pendingFilters = navState.initialFilters;
      if (pendingFilters != null) {
        setState(() => _uiFilters = pendingFilters);
        context.read<ProductBloc>().add(
              ApplyFiltersEvent(filters: _toProductFilters()),
            );
      } else if (pendingQuery != null && pendingQuery.isNotEmpty) {
        _applySearchQuery(pendingQuery);
      } else if (context.read<ProductBloc>().state is ProductInitial) {
        context.read<ProductBloc>().add(const LoadProductsEvent(
              filters: ProductFilters(),
            ));
      }
    });
  }

  void _applySearchQuery(String query) {
    _searchController.text = query;
    setState(() {
      _mode = _SearchMode.globalSearch;
      _uiFilters = _uiFilters.copyWith(searchQuery: query);
    });
    context.read<ProductBloc>().add(
          ApplyFiltersEvent(filters: _toProductFilters()),
        );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _aiSearchDebounce?.cancel();
    _searchController.dispose();
    _aiSearchController.dispose();
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

  /// Builds the `activeFilters` payload sent alongside an AI Search query, so
  /// the backend knows whether the user is refining an existing search.
  Map<String, dynamic>? _activeFiltersPayload() {
    final filters = _toProductFilters();
    final payload = <String, dynamic>{};
    if (filters.category != null) payload['category'] = filters.category;
    if (filters.minPrice != null) payload['minPrice'] = filters.minPrice;
    if (filters.maxPrice != null) payload['maxPrice'] = filters.maxPrice;
    if (filters.search != null) payload['search'] = filters.search;
    return payload.isEmpty ? null : payload;
  }

  void _onAiQueryChanged(String value) {
    setState(() {});
    _aiSearchDebounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<AiSearchBloc>().add(const ClearAiSearchEvent());
      _clearFilters();
      return;
    }
    _aiSearchDebounce = Timer(
      const Duration(milliseconds: 900),
      () => _runAiSearch(value),
    );
  }

  void _runAiSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    context.read<AiSearchBloc>().add(
          RunAiSearchEvent(query: query, activeFilters: _activeFiltersPayload()),
        );
  }

  void _onAiSearchLoaded(AiSearchFilters filters) {
    setState(() {
      _uiFilters = NumberFilters(searchQuery: _aiSearchController.text.trim());
    });
    context.read<ProductBloc>().add(
          ApplyFiltersEvent(filters: _productFiltersFromAiRaw(filters.raw)),
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

  Future<void> _openAdvancedSearch() async {
    final result = await Navigator.pushNamed<ProductFilters>(context, Routes.advancedSearch);
    if (result != null && mounted) {
      context.read<ProductBloc>().add(ApplyFiltersEvent(filters: result));
    }
  }

  /// Reissues the search with one advanced-search pattern field removed
  /// (used by the "Starts With"/"Anywhere"/"Ends With" filter chip's ✕).
  void _removeAdvancedFilter(
    ProductsLoaded state, {
    bool startsWith = false,
    bool endsWith = false,
    bool anywhere = false,
  }) {
    final current = state.appliedFilters;
    final updatedAdvanced = current.advanced?.clearing(
      startsWith: startsWith,
      endsWith: endsWith,
      anywhere: anywhere,
    );
    final newFilters = ProductFilters(
      search: current.search,
      category: current.category,
      minPrice: current.minPrice,
      maxPrice: current.maxPrice,
      sortBy: current.sortBy,
      sortPrice: current.sortPrice,
      readyToPort: current.readyToPort,
      random: current.random,
      seed: current.seed,
      advanced:
          updatedAdvanced != null && !updatedAdvanced.isEmpty ? updatedAdvanced : null,
    );
    context.read<ProductBloc>().add(ApplyFiltersEvent(filters: newFilters));
  }

  void _clearFilters() {
    setState(() {
      _uiFilters = const NumberFilters();
      _searchController.clear();
    });
    _aiSearchDebounce?.cancel();
    context.read<AiSearchBloc>().add(const ClearAiSearchEvent());
    context.read<ProductBloc>().add(const ClearFiltersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AppNavigationCubit, AppNavigationState>(
          listenWhen: (prev, curr) =>
              curr.selectedIndex == 1 &&
              curr.initialSearchQuery != null &&
              curr.initialSearchQuery != prev.initialSearchQuery,
          listener: (context, state) {
            final query = state.initialSearchQuery!;
            _searchDebounce?.cancel();
            _applySearchQuery(query);
          },
        ),
        BlocListener<AiSearchBloc, AiSearchState>(
          listener: (context, state) {
            if (state is AiSearchLoaded) {
              _onAiSearchLoaded(state.filters);
            } else if (state is AiSearchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(theme),
            _buildTabs(theme),
            _buildSearchRow(theme),

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

            // Advanced search pattern-filter chips (Starts With / Anywhere / Ends With)
            BlocBuilder<ProductBloc, ProductState>(
              buildWhen: (previous, current) => current is ProductsLoaded,
              builder: (context, state) {
                if (state is! ProductsLoaded) return const SizedBox.shrink();
                final advanced = state.appliedFilters.advanced;
                if (advanced == null || advanced.isEmpty) {
                  return const SizedBox.shrink();
                }

                final chips = <Widget>[
                  if (advanced.startsWith?.isNotEmpty ?? false)
                    _ActiveFilterChip(
                      label: 'Starts With: ${advanced.startsWith}',
                      onRemove: () => _removeAdvancedFilter(state, startsWith: true),
                    ),
                  if (advanced.anywhere?.isNotEmpty ?? false)
                    _ActiveFilterChip(
                      label: 'Anywhere: ${advanced.anywhere}',
                      onRemove: () => _removeAdvancedFilter(state, anywhere: true),
                    ),
                  if (advanced.endsWith?.isNotEmpty ?? false)
                    _ActiveFilterChip(
                      label: 'Ends With: ${advanced.endsWith}',
                      onRemove: () => _removeAdvancedFilter(state, endsWith: true),
                    ),
                ];
                if (chips.isEmpty) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_alt_outlined,
                              size: 16, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            'Active Filters (${chips.length})',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: chips),
                    ],
                  ),
                );
              },
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

                  if (products.isEmpty &&
                      state is ProductsLoaded &&
                      (state.closestMatches?.isNotEmpty ?? false)) {
                    return _buildClosestMatchesFallback(theme, state);
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
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) =>
                              _buildProductCard(context, products[index]),
                        ),
                      ),
                      if (isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic pn) {
    return ProductCard(
      phoneNumber: pn.number,
      price: pn.price,
      category: pn.category,
      features: List<String>.from(pn.features),
      discount: pn.discount > 0 ? pn.discount.toDouble() : null,
      isFeatured: pn.isFeatured,
      numerology: pn.numerology,
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
  }

  /// Shown instead of a flat "No Numbers Found" screen when an advanced
  /// search for "Starts With"/"Ends With" comes back with zero exact
  /// matches: surfaces per-filter "closest match" suggestions fetched via
  /// the Similar Number Fetch API (see [ProductBloc._buildClosestMatchGroups]).
  Widget _buildClosestMatchesFallback(ThemeData theme, ProductsLoaded state) {
    final groups = state.closestMatches ?? const [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            "We couldn't find an exact match for your selected filters. "
            "Here are some great alternatives we found for you instead:",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (final group in groups) ...[
          const SizedBox(height: 20),
          _buildClosestMatchSectionHeader(theme, group.label),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: group.products.length,
            itemBuilder: (context, index) =>
                _buildProductCard(context, group.products[index]),
          ),
        ],
      ],
    );
  }

  Widget _buildClosestMatchSectionHeader(ThemeData theme, String label) {
    final line = Divider(color: theme.colorScheme.primary.withValues(alpha: 0.4));
    return Row(
      children: [
        Expanded(child: line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_alt, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: line),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      color: theme.colorScheme.surface,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 2,
            left: -8,
            child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 18),
          ),
          Positioned(
            top: 2,
            right: -8,
            child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 18),
          ),
          Column(
            children: [
              Text(
                'Buy VIP Mobile Number - Fancy Mobile Numbers',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Find & Choose from our exclusive collection of VIP mobile '
                'numbers. Select your preferred number, complete the payment, '
                'and our team will handle the porting process.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'AI Search',
              icon: Icons.auto_awesome,
              isSelected: _mode == _SearchMode.aiSearch,
              onTap: () => setState(() => _mode = _SearchMode.aiSearch),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Global Search',
              isSelected: _mode == _SearchMode.globalSearch,
              onTap: () => setState(() => _mode = _SearchMode.globalSearch),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Price Filter',
              isSelected: false,
              onTap: _openFilterSheet,
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Adv. Search',
              isSelected: false,
              onTap: _openAdvancedSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: _openSortSheet,
            icon: const Icon(Icons.unfold_more, size: 18),
            label: const Text('Sort'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _mode == _SearchMode.aiSearch
                ? _buildAiSearchField(theme)
                : _buildGlobalSearchField(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSearchField(ThemeData theme) {
    return BlocBuilder<AiSearchBloc, AiSearchState>(
      builder: (context, state) {
        final isLoading = state is AiSearchLoading;
        final border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        );

        return TextField(
          controller: _aiSearchController,
          decoration: InputDecoration(
            hintText: 'e.g. req mirror numbers',
            prefixIcon: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _aiSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _aiSearchController.clear();
                          _onAiQueryChanged('');
                        },
                      )
                    : null,
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textInputAction: TextInputAction.search,
          onChanged: _onAiQueryChanged,
          onSubmitted: (value) {
            _aiSearchDebounce?.cancel();
            _runAiSearch(value);
          },
        );
      },
    );
  }

  Widget _buildGlobalSearchField(ThemeData theme) {
    return TextField(
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
                  context.read<ProductBloc>().add(
                        ApplyFiltersEvent(filters: _toProductFilters()),
                      );
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() => _uiFilters = _uiFilters.copyWith(searchQuery: value));
        _searchDebounce?.cancel();
        _searchDebounce = Timer(const Duration(milliseconds: 500), () {
          context.read<ProductBloc>().add(
                ApplyFiltersEvent(filters: _toProductFilters()),
              );
        });
      },
    );
  }
}

/// Converts the raw filter map returned by the AI Search API into the
/// product catalog's [ProductFilters]. The API's response already accounts
/// for whatever `activeFilters` were sent, so this replaces the current
/// filters outright rather than merging with them.
ProductFilters _productFiltersFromAiRaw(Map<String, dynamic> raw) {
  String? str(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  double? dbl(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? intVal(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool? boolVal(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  String? mostContainDigit = str(raw['mostContainDigit']);
  int? mostContainCount = intVal(raw['mostContainCount']);
  final nestedMostContain = raw['mostContain'];
  if (nestedMostContain is Map) {
    mostContainDigit ??= str(nestedMostContain['digit']);
    mostContainCount ??= intVal(nestedMostContain['count']);
  }

  final advanced = AdvancedSearchFilters(
    startsWith: str(raw['startsWith']),
    endsWith: str(raw['endsWith']),
    anywhere: str(raw['anywhere']),
    mustContain: str(raw['mustContain']),
    notContain: str(raw['notContain']),
    literSum: intVal(raw['literSum']),
    trapSum: intVal(raw['trapSum']),
    scoreSum: intVal(raw['scoreSum']),
    exactDigitPlacement: str(raw['exactDigitPlacement']),
    mostContainDigit: mostContainDigit,
    mostContainCount: mostContainCount,
  );

  return ProductFilters(
    search: str(raw['search']),
    category: str(raw['category']),
    minPrice: dbl(raw['minPrice']),
    maxPrice: dbl(raw['maxPrice']),
    sortPrice: str(raw['sortPrice']),
    readyToPort: str(raw['readyToPort']),
    random: boolVal(raw['random']),
    advanced: advanced.isEmpty ? null : advanced,
  );
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
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
