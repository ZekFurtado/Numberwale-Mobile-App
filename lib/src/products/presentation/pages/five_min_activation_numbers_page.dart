import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/product_actions.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/vip_number_card.dart';
import 'package:numberwale/src/home/domain/entities/category.dart';
import 'package:numberwale/src/home/domain/usecases/get_categories.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

const _orange = Color(0xFFFF8401);
const _navy = Color(0xFF0F1A3C);

/// States NumberWale's operator-provided 5-min activation SIMs are
/// currently issued from. Shown in the "Search by State" picker.
const _operatorStates = [
  'Maharashtra',
  'Mumbai',
  'Gujarat',
  'Karnataka',
  'Assam',
  'Bihar',
  'Himachal Pradesh',
  'Delhi',
];

/// "5 Mins Activation Numbers" page: numbers sourced directly from telecom
/// operators (see `GET /products/get-products?isDirectFromOperator=true`),
/// ready for instant activation in the buyer's home state.
class FiveMinActivationNumbersPage extends StatefulWidget {
  const FiveMinActivationNumbersPage({super.key});

  @override
  State<FiveMinActivationNumbersPage> createState() =>
      _FiveMinActivationNumbersPageState();
}

class _FiveMinActivationNumbersPageState
    extends State<FiveMinActivationNumbersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Category> _categories = [];
  Category? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  String _searchQuery = '';
  String? _selectedState;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ProductBloc>().add(
          LoadProductsEvent(filters: _buildFilters()),
        );
    di.sl<GetCategories>()().then((result) {
      if (!mounted) return;
      result.fold((_) {}, (categories) {
        setState(() => _categories = categories);
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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

  /// Builds the API filters: always scoped to operator-direct numbers, plus
  /// whatever category/price/search/state the user has picked. [category]
  /// is sent by its real backend slug (e.g. `mirror-numbers`), never a
  /// guessed transform of the display name.
  ProductFilters _buildFilters() {
    return ProductFilters(
      isDirectFromOperator: true,
      operatorState: _selectedState,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      category: _selectedCategory?.slug,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
  }

  void _reload() {
    context.read<ProductBloc>().add(
          ApplyFiltersEvent(filters: _buildFilters()),
        );
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), _reload);
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_CategoryPriceSelection>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FiltersSheet(
        categories: _categories,
        selectedCategory: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategory = result.category;
        _minPrice = result.minPrice;
        _maxPrice = result.maxPrice;
      });
      _reload();
    }
  }

  Future<void> _openStatePicker() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _StatePickerSheet(selected: _selectedState),
    );
    if (result != _selectedState) {
      setState(() => _selectedState = result);
      _reload();
    }
  }

  void _scrollToList() {
    _scrollController.animateTo(
      520,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
      _selectedState = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF5EE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(onActivateTap: _scrollToList),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _StateDropdownPill(
                    selectedState: _selectedState,
                    onTap: _openStatePicker,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchRow(
                    controller: _searchController,
                    categoryLabel: _selectedCategory?.name ?? 'ALL',
                    onCategoryTap: _openFilterSheet,
                    onChanged: _onSearchChanged,
                    onSearch: () {
                      _searchDebounce?.cancel();
                      _reload();
                    },
                    onFilterTap: _openFilterSheet,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading || state is ProductInitial) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is ProductError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _reload,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              List<dynamic> products = [];
              bool isLoadingMore = false;
              if (state is ProductsLoaded) {
                products = state.products;
              } else if (state is ProductLoadingMore) {
                products = state.currentProducts;
                isLoadingMore = true;
              }

              if (products.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.bolt_outlined,
                    title: 'No 5-Min Activation Numbers',
                    message:
                        'Try a different state or adjust your filters.',
                    actionLabel: 'Clear Filters',
                    onAction: _clearFilters,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final pn = products[index];
                      // Wrapped in WishlistAware: this delegate's `context`
                      // is the shared sliver context, unsafe for select.
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WishlistAware(
                          itemId: pn.id,
                          builder: (context, isWishlisted) => VipNumberCard(
                            phoneNumber: pn.number,
                            price: pn.price,
                            category: pn.category,
                            numerology: pn.numerology,
                            operatorProvider: pn.operatorProvider,
                            operatorState: pn.operatorState,
                            isWishlisted: isWishlisted,
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.productDetail,
                              arguments: pn.number,
                            ),
                            onAddToCart: () =>
                                ProductActions.addToCart(context, pn),
                            onBuyNow: () =>
                                ProductActions.buyNow(context, pn),
                            onEnquire: () =>
                                ProductActions.enquire(context, pn),
                            onWishlist: () =>
                                ProductActions.toggleWishlist(context, pn),
                          ),
                        ),
                      );
                    },
                    childCount: products.length + (isLoadingMore ? 1 : 0),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onActivateTap});

  final VoidCallback onActivateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9A44), Color(0xFFF06A16)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'JIO SPECIAL',
                        style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          height: 1.1,
                        ),
                        children: [
                          TextSpan(text: '5-MIN ', style: TextStyle(color: _navy)),
                          TextSpan(
                              text: 'ACTIVATION',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'FOR YOUR HOME STATE VIP NUMBER',
                      style: TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const _MapGraphic(),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Ready to use in as little as 5 minutes.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FeatureChip(icon: Icons.bolt, label: '5-MIN\nACTIVATION'),
              _FeatureChip(
                  icon: Icons.location_on_outlined, label: 'HOME STATE\nNUMBERS'),
              _FeatureChip(
                  icon: Icons.verified_user_outlined, label: 'TRUSTED\nPLATFORM'),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: onActivateTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACTIVATE IN 5 MINUTES',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGraphic extends StatelessWidget {
  const _MapGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
          ),
          Icon(Icons.map_outlined,
              color: Colors.white.withValues(alpha: 0.85), size: 48),
          const Positioned(
            top: 6,
            right: 4,
            child: Icon(Icons.location_on, color: Colors.white, size: 18),
          ),
          const Positioned(
            bottom: 10,
            left: 2,
            child: Icon(Icons.location_on, color: Colors.white, size: 16),
          ),
          Positioned(
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sim_card, color: _navy, size: 12),
                  SizedBox(width: 3),
                  Text(
                    '5 MIN',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _orange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateDropdownPill extends StatelessWidget {
  const _StateDropdownPill({required this.selectedState, required this.onTap});

  final String? selectedState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Search by State (${selectedState ?? 'All'})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatePickerSheet extends StatelessWidget {
  const _StatePickerSheet({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search by State',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('All'),
              trailing: selected == null ? const Icon(Icons.check, color: _orange) : null,
              onTap: () => Navigator.pop(context, null),
            ),
            for (final state in _operatorStates)
              ListTile(
                title: Text(state),
                trailing:
                    selected == state ? const Icon(Icons.check, color: _orange) : null,
                onTap: () => Navigator.pop(context, state),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPriceSelection {
  const _CategoryPriceSelection({this.category, this.minPrice, this.maxPrice});

  final Category? category;
  final double? minPrice;
  final double? maxPrice;
}

const _pricePresets = [
  ('Under ₹10K', 0.0, 10000.0),
  ('₹10K - ₹25K', 10000.0, 25000.0),
  ('₹25K - ₹50K', 25000.0, 50000.0),
  ('Above ₹1L', 100000.0, 10000000.0),
];

/// Mirrors the desktop "Filters" panel's Categories/Prices tabs: real
/// backend categories (fetched via [GetCategories]) and a price range,
/// applied together via the bottom "Apply Filters" button.
class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.categories,
    required this.selectedCategory,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<Category> categories;
  final Category? selectedCategory;
  final double? minPrice;
  final double? maxPrice;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late Category? _category = widget.selectedCategory;
  late double? _minPrice = widget.minPrice;
  late double? _maxPrice = widget.maxPrice;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _category = null;
                      _minPrice = null;
                      _maxPrice = null;
                    }),
                    child: const Text('Reset'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterTabButton(
                      label: 'Categories',
                      isSelected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilterTabButton(
                      label: 'Prices',
                      isSelected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _tab == 0
                  ? _buildCategoryList(scrollController)
                  : _buildPriceTab(scrollController),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  _CategoryPriceSelection(
                    category: _category,
                    minPrice: _minPrice,
                    maxPrice: _maxPrice,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryList(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      children: [
        ListTile(
          title: const Text('All'),
          trailing:
              _category == null ? const Icon(Icons.check, color: _orange) : null,
          onTap: () => setState(() => _category = null),
        ),
        for (final cat in widget.categories)
          ListTile(
            title: Text(cat.name),
            trailing: _category?.slug == cat.slug
                ? const Icon(Icons.check, color: _orange)
                : null,
            onTap: () => setState(() => _category = cat),
          ),
      ],
    );
  }

  Widget _buildPriceTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final preset in _pricePresets)
          ListTile(
            title: Text(preset.$1),
            trailing: (_minPrice == preset.$2 && _maxPrice == preset.$3)
                ? const Icon(Icons.check, color: _orange)
                : null,
            onTap: () => setState(() {
              _minPrice = preset.$2;
              _maxPrice = preset.$3;
            }),
          ),
      ],
    );
  }
}

class _FilterTabButton extends StatelessWidget {
  const _FilterTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _orange : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.categoryLabel,
    required this.onCategoryTap,
    required this.onChanged,
    required this.onSearch,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final String categoryLabel;
  final VoidCallback onCategoryTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onCategoryTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryLabel.length > 10
                        ? '${categoryLabel.substring(0, 10)}…'
                        : categoryLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Search any number...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: onChanged,
              onSubmitted: (_) => onSearch(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: _orange),
            tooltip: 'Filters',
            onPressed: onFilterTap,
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
