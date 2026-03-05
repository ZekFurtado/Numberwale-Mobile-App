import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/number_display_card.dart';
import 'package:numberwale/core/widgets/numerology_card.dart';
import 'package:numberwale/core/widgets/price_display.dart';
import 'package:numberwale/core/widgets/product_info_card.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return _ProductDetailView(phoneNumber: phoneNumber);
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView({required this.phoneNumber});

  final String phoneNumber;

  String _rtpLabel(PhoneNumber product) {
    if (product.isRTP) return 'Ready to Port';
    if (product.isCRTP) return 'Conditionally Ready to Port';
    return 'Not Available';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Loading
        if (state is ProductLoading || state is ProductInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (state is ProductError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Details')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<ProductBloc>()
                        .add(LoadProductByNumberEvent(number: phoneNumber)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! ProductDetailLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final product = state.product;
        final numerology = product.numerology;
        final literSum = numerology?['liters'] as int?;
        final trapSum = numerology?['trap'] as int?;
        final scoreSum = numerology?['score'] as int?;
        final hasDiscount = product.discount > 0;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                title: const Text('Product Details'),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, Routes.cart),
                    icon: const Icon(Icons.shopping_cart),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Hero(
                      tag: 'product_number_${product.number}',
                      child: NumberDisplayCard(
                        phoneNumber: product.number,
                        isFeatured: product.isFeatured,
                      ),
                    ),

                    const SizedBox(height: 20),

                    PriceDisplay(
                      price: product.price,
                      originalPrice: hasDiscount ? product.originalPrice : null,
                      discount: hasDiscount ? product.discount.toDouble() : null,
                    ),

                    const SizedBox(height: 16),

                    ProductInfoCard(
                      operator: product.operator,
                      category: product.category,
                      rtp: _rtpLabel(product),
                      availability: product.isAvailable ? 'Available' : 'Sold Out',
                      features: product.features,
                    ),

                    const SizedBox(height: 16),

                    NumerologyCard(
                      literSum: literSum,
                      trapSum: trapSum,
                      scoreSum: scoreSum,
                    ),

                    const SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Looking for Similar Numbers?',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Request a custom number pattern matching your preferences',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                  context, Routes.customRequest),
                              icon: const Icon(Icons.search),
                              label: const Text('Request Similar Pattern'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),

          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: product.id != null
                          ? () {
                              context
                                  .read<CartBloc>()
                                  .add(AddToCartEvent(productId: product.id!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.number} added to cart'),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () => Navigator.pushNamed(
                                        context, Routes.cart),
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, Routes.numerologyConsultation),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Consult'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
