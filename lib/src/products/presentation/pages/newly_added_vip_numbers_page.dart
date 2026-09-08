import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/product_card.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

/// Paginated "See All" destination for the home screen's
/// "Newly Added VIP Numbers" section. Fetches from
/// `GET /api/v1/products/get-products` with `recentDays=7&sort=-createdAt`.
///
/// Unlike the Explore page's infinite scroll, this page shows numbered page
/// buttons, so `skipCount` is left off the request (unlike the home screen
/// preview) - the total page count has to come back from the API.
class NewlyAddedVipNumbersPage extends StatefulWidget {
  const NewlyAddedVipNumbersPage({super.key});

  static const _filters = ProductFilters(
    recentDays: 7,
    sort: '-createdAt',
    limit: 12,
  );

  @override
  State<NewlyAddedVipNumbersPage> createState() =>
      _NewlyAddedVipNumbersPageState();
}

class _NewlyAddedVipNumbersPageState extends State<NewlyAddedVipNumbersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPage(int page) {
    context.read<ProductBloc>().add(
          LoadProductsEvent(
            filters: NewlyAddedVipNumbersPage._filters.copyWith(page: page),
          ),
        );
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Newly Added VIP Numbers')),
      body: BlocBuilder<ProductBloc, ProductState>(
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
                    onPressed: () => _loadPage(1),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! ProductsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = state.products;

          if (products.isEmpty) {
            return const EmptyState(
              icon: Icons.fiber_new_outlined,
              title: 'No New Numbers Yet',
              message: 'Check back soon for freshly added VIP numbers.',
            );
          }

          return Column(
            children: [
              if (state.totalPages > 1)
                _PageSelector(
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  onSelect: _loadPage,
                ),
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final pn = products[index];
                    return ProductCard(
                      phoneNumber: pn.number,
                      price: pn.price,
                      category: pn.category,
                      features: List<String>.from(pn.features),
                      discount:
                          pn.discount > 0 ? pn.discount.toDouble() : null,
                      isFeatured: pn.isFeatured,
                      numerology: pn.numerology,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.productDetail,
                        arguments: pn.number,
                      ),
                      onAddToCart: () {
                        if (pn.id != null) {
                          context
                              .read<CartBloc>()
                              .add(AddToCartEvent(productId: pn.id!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${pn.number} added to cart')),
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
    );
  }
}

/// Numbered page controls (Prev / 1 2 … N / Next), windowed around the
/// current page so it stays usable when there are many pages. Rendered as a
/// normal (non-overlay) block above the grid: a horizontally scrollable row
/// of buttons, centered when it's narrower than the screen.
class _PageSelector extends StatelessWidget {
  const _PageSelector({
    required this.currentPage,
    required this.totalPages,
    required this.onSelect,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onSelect;

  List<int?> _pageNumbers() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final keep = <int>{1, totalPages, currentPage};
    if (currentPage > 1) keep.add(currentPage - 1);
    if (currentPage < totalPages) keep.add(currentPage + 1);
    final sorted = keep.toList()..sort();

    final result = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) result.add(null);
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = _pageNumbers();

    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? () => onSelect(currentPage - 1) : null,
        ),
        for (final page in pages)
          page == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text('…'),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _PageNumberButton(
                    page: page,
                    isSelected: page == currentPage,
                    onTap: () => onSelect(page),
                  ),
                ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPages ? () => onSelect(currentPage + 1) : null,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Center(child: buttons),
            ),
          );
        },
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final int page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: isSelected ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          '$page',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
