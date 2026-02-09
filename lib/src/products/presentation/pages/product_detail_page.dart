import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/number_display_card.dart';
import 'package:numberwale/core/widgets/numerology_card.dart';
import 'package:numberwale/core/widgets/price_display.dart';
import 'package:numberwale/core/widgets/product_info_card.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  // Mock data - will be replaced with actual API call
  Map<String, dynamic> _getProductDetails() {
    return {
      'phoneNumber': phoneNumber,
      'price': 25000.0,
      'originalPrice': 30000.0,
      'discount': 16.67,
      'operator': 'Airtel',
      'category': 'VIP',
      'rtp': 'Available',
      'availability': 'Available',
      'features': ['Sequential', 'Premium', 'Easy to Remember'],
      'isFeatured': true,
      'literSum': 7,
      'trapSum': 4,
      'scoreSum': 9,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = _getProductDetails();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            title: const Text('Product Details'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.cart);
                },
                icon: const Icon(Icons.shopping_cart),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Large number display with hero animation
                Hero(
                  tag: 'product_number_$phoneNumber',
                  child: NumberDisplayCard(
                    phoneNumber: product['phoneNumber'],
                    isFeatured: product['isFeatured'] ?? false,
                  ),
                ),

                const SizedBox(height: 20),

                // Price card
                PriceDisplay(
                  price: product['price'],
                  originalPrice: product['originalPrice'],
                  discount: product['discount'],
                ),

                const SizedBox(height: 16),

                // Product info card
                ProductInfoCard(
                  operator: product['operator'],
                  category: product['category'],
                  rtp: product['rtp'],
                  availability: product['availability'],
                  features: List<String>.from(product['features']),
                ),

                const SizedBox(height: 16),

                // Numerology card (expandable)
                NumerologyCard(
                  literSum: product['literSum'],
                  trapSum: product['trapSum'],
                  scoreSum: product['scoreSum'],
                ),

                const SizedBox(height: 16),

                // Similar numbers section placeholder
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
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.customRequest);
                          },
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

                // Bottom padding for sticky button
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),

      // Sticky bottom action buttons
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
              // Add to Cart button
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    // Add to cart logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product['phoneNumber']} to cart!'),
                        action: SnackBarAction(
                          label: 'View Cart',
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.cart);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Numerology consultation button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.numerologyConsultation);
                  },
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
  }
}
