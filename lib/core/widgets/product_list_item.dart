import 'package:flutter/material.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.phoneNumber,
    required this.price,
    required this.category,
    this.features = const [],
    this.discount,
    this.isFeatured = false,
    this.onTap,
    this.onAddToCart,
  });

  final String phoneNumber;
  final double price;
  final String category;
  final List<String> features;
  final double? discount;
  final bool isFeatured;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    }
    return '₹${price.toInt()}';
  }

  int _digitSum(String number) {
    return number
        .replaceAll(RegExp(r'[^0-9]'), '')
        .split('')
        .fold(0, (sum, d) => sum + int.parse(d));
  }

  int _digitalRoot(int n) {
    while (n >= 10) {
      n = n
          .toString()
          .split('')
          .fold(0, (sum, d) => sum + int.parse(d));
    }
    return n;
  }

  /// Splits a 10-digit number into groups: X XXX XXX XXX
  List<String> _getNumberGroups(String number) {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return [
        digits.substring(0, 1),
        digits.substring(1, 4),
        digits.substring(4, 7),
        digits.substring(7, 10),
      ];
    }
    return [number];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final groups = _getNumberGroups(phoneNumber);
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final sumTotal = _digitSum(digits);
    final root = _digitalRoot(sumTotal);
    final hasDiscount = discount != null && discount! > 0;
    final discountedPrice = hasDiscount ? price * (1 - discount! / 100) : price;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isFeatured ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isFeatured
            ? BorderSide(color: primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            children: [
              // Top row: phone icon | number | verified badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Phone icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.smartphone, color: primary, size: 22),
                  ),
                  const SizedBox(width: 8),

                  // Number with alternating orange / dark groups
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          for (int i = 0; i < groups.length; i++) ...[
                            if (i > 0)
                              const TextSpan(
                                text: ' ',
                                style: TextStyle(fontSize: 24),
                              ),
                            TextSpan(
                              text: groups[i],
                              style: TextStyle(
                                color: i.isEven
                                    ? primary
                                    : const Color(0xFF2D3748),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Verified badge
                  Icon(Icons.verified, color: Colors.blue.shade600, size: 24),
                ],
              ),

              const SizedBox(height: 10),

              // Category chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // SUM TOTAL row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SUM TOTAL = ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                  _SumBadge(
                    value: sumTotal.toString(),
                    color: const Color(0xFFBFD0FF),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '=',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _SumBadge(
                    value: root.toString(),
                    color: const Color(0xFFD4C5FF),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price
              Text(
                _formatPrice(discountedPrice),
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 16),

              // Buy Now + Cart button row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 44, vertical: 13),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Buy Now'),
                  ),
                  if (onAddToCart != null) ...[
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primary, width: 2),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SumBadge extends StatelessWidget {
  const _SumBadge({required this.value, required this.color});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }
}
