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
                      const SizedBox(height: 4),
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
        const SizedBox(height: 16),

        // Horizontal scrollable list
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: numbers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final number = numbers[index];
              return SizedBox(
                width: 280,
                child: ProductCard(
                  phoneNumber: number.phoneNumber,
                  price: number.price,
                  category: number.category,
                  features: number.features,
                  discount: number.discount,
                  isFeatured: number.isFeatured,
                  onTap: number.onTap,
                  onAddToCart: number.onAddToCart,
                ),
              );
            },
          ),
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
