import 'package:flutter/material.dart';
import 'package:numberwale/core/widgets/product_card.dart';

class FeaturedNumbersSection extends StatelessWidget {
  const FeaturedNumbersSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.numbers,
    this.onSeeAllTap,
  });

  final String title;
  final String? subtitle;
  final List<FeaturedNumber> numbers;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2-column grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            final n = numbers[index];
            return ProductCard(
              phoneNumber: n.phoneNumber,
              price: n.price,
              category: n.category,
              features: n.features,
              discount: n.discount,
              isFeatured: n.isFeatured,
              onTap: n.onTap,
              onAddToCart: n.onAddToCart,
            );
          },
        ),
      ],
    );
  }
}

class FeaturedNumber {
  final String phoneNumber;
  final double price;
  final String category;
  final List<String> features;
  final double? discount;
  final bool isFeatured;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const FeaturedNumber({
    required this.phoneNumber,
    required this.price,
    required this.category,
    this.features = const [],
    this.discount,
    this.isFeatured = false,
    this.onTap,
    this.onAddToCart,
  });
}
