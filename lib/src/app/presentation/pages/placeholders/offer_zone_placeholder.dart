import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/product_card.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

class OfferZonePlaceholder extends StatelessWidget {
  const OfferZonePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // Own ProductBloc instance so it doesn't conflict with the Explore page
    return BlocProvider(
      create: (_) => di.sl<ProductBloc>(),
      child: const _OfferZoneContent(),
    );
  }
}

class _OfferZoneContent extends StatefulWidget {
  const _OfferZoneContent();

  @override
  State<_OfferZoneContent> createState() => _OfferZoneContentState();
}

class _OfferZoneContentState extends State<_OfferZoneContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(
            const LoadDiscountedProductsEvent(filters: ProductFilters()),
          );
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading || state is ProductInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.read<ProductBloc>().add(
                        const LoadDiscountedProductsEvent(
                            filters: ProductFilters()),
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
          return const EmptyState(
            icon: Icons.local_offer_outlined,
            title: 'No Offers Available',
            message: 'Check back soon for discounted numbers.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$totalCount discounted numbers',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Product grid
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final pn = products[index];
                  return ProductCard(
                    phoneNumber: pn.number,
                    price: pn.originalPrice?.toDouble() ?? pn.price,
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
                        context.read<CartBloc>().add(AddToCartEvent(
                              productId: pn.id!,
                              productNumber: pn.number,
                              price: pn.price,
                            ));
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
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
