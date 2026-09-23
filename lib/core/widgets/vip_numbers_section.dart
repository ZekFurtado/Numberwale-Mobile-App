import 'package:flutter/material.dart';
import 'package:numberwale/core/widgets/vip_number_card.dart';

const _orange = Color(0xFFFF8401);

/// Home screen section rendering a title (with an optional badge), a
/// centered subtitle, and a single-column list of [VipNumberCard]s. Used for
/// both "Newly Added VIP Numbers" and "Premium Numbers".
class VipNumbersSection extends StatelessWidget {
  const VipNumbersSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.numbers,
    this.badgeLabel,
    this.badgeIcon,
    this.onSeeAllTap,
  });

  final String title;
  final String subtitle;
  final List<VipNumber> numbers;
  final String? badgeLabel;
  final IconData? badgeIcon;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (badgeLabel != null)
                    _Badge(label: badgeLabel!, icon: badgeIcon),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onSeeAllTap != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onSeeAllTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('See All'),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < numbers.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                VipNumberCard(
                  phoneNumber: numbers[i].phoneNumber,
                  price: numbers[i].price,
                  category: numbers[i].category,
                  numerology: numbers[i].numerology,
                  isWishlisted: numbers[i].isWishlisted,
                  onTap: numbers[i].onTap,
                  onAddToCart: numbers[i].onAddToCart,
                  onBuyNow: numbers[i].onBuyNow,
                  onEnquire: numbers[i].onEnquire,
                  onWishlist: numbers[i].onWishlist,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: _orange),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: _orange,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class VipNumber {
  final String phoneNumber;
  final double price;
  final String category;
  final Map<String, dynamic>? numerology;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback? onEnquire;
  final VoidCallback? onWishlist;

  const VipNumber({
    required this.phoneNumber,
    required this.price,
    required this.category,
    this.numerology,
    this.isWishlisted = false,
    this.onTap,
    this.onAddToCart,
    this.onBuyNow,
    this.onEnquire,
    this.onWishlist,
  });
}
