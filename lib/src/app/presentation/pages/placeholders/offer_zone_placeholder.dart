import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/product_actions.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/vip_number_card.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
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

  /// The API doesn't return a deal deadline, so each discounted number gets
  /// a stable (per session), deterministic "ends in" countdown seeded from
  /// its id — cached here so it doesn't reshuffle on every rebuild.
  final Map<String, DateTime> _dealEndsAtCache = {};

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

  DateTime _dealEndsAtFor(String seed) {
    return _dealEndsAtCache.putIfAbsent(seed, () {
      const minSeconds = 6 * 3600;
      const maxSeconds = 5 * 24 * 3600;
      final secondsFromNow =
          minSeconds + (seed.hashCode.abs() % (maxSeconds - minSeconds));
      return DateTime.now().add(Duration(seconds: secondsFromNow));
    });
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

        List<PhoneNumber> products = [];
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

            // Product list
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: products.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final pn = products[index];
                  final hasDiscount = pn.discount > 0 && pn.originalPrice != null;
                  // Wrapped in WishlistAware: itemBuilder's `context` is the
                  // shared sliver context, unsafe for context.select.
                  return WishlistAware(
                    itemId: pn.id,
                    builder: (context, isWishlisted) => VipNumberCard(
                      phoneNumber: pn.number,
                      price: pn.price,
                      category: pn.category,
                      numerology: pn.numerology,
                      originalPrice: pn.originalPrice,
                      discount: hasDiscount ? pn.discount : null,
                      dealEndsAt: hasDiscount
                          ? _dealEndsAtFor(pn.id ?? pn.number)
                          : null,
                      isWishlisted: isWishlisted,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.productDetail,
                        arguments: pn.number,
                      ),
                      onAddToCart: () => ProductActions.addToCart(context, pn),
                      onBuyNow: () => ProductActions.buyNow(context, pn),
                      onEnquire: () => ProductActions.enquire(context, pn),
                      onWishlist: () =>
                          ProductActions.toggleWishlist(context, pn),
                    ),
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
