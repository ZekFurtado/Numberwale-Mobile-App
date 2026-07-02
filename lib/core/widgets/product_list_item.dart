import 'package:flutter/material.dart';

const _orange = Color(0xFFFF8401);
const _cardBg = Color(0xFFFFFFFF);
// const _cardBg = Color(0xFFFFF8F0);
const _cardBorder = Color(0xFFFFD0A0);
const _enquireDark = Color(0xFF2D3748);

class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.phoneNumber,
    required this.price,
    required this.category,
    this.features = const [],
    this.discount,
    this.isFeatured = false,
    this.isPremium = false,
    this.isEnquiry = false,
    this.isWishlisted = false,
    this.numerology,
    this.onTap,
    this.onAddToCart,
    this.onWishlist,
    this.onSimilar,

  });

  final String phoneNumber;
  final double price;
  final String category;
  final List<String> features;
  final double? discount;
  final bool isFeatured;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isPremium;
  final bool isEnquiry;
  final bool isWishlisted;
  final Map<String, dynamic>? numerology;
  final VoidCallback? onWishlist;
  final VoidCallback? onSimilar;

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

  String _formatPhoneNumber(String number) {
    if (number.length == 10) {
      return '${number.substring(0, 5)} ${number.substring(5)}';
    }
    return number;
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
    final sum = (numerology?['liters'] ?? numerology?['sum']) as int?;
    final score = numerology?['score'] as int?;
    final trap = numerology?['trap'] as int?;
    final hasNumerology = sum != null || score != null;
    final displayPrice = hasDiscount ? price * (1 - discount! / 100) : price;
    final effectiveIsEnquiry = isEnquiry || (price * 1.18 > 500000);


    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Orange phone number pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatPhoneNumber(phoneNumber),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Category row: phone icon + badge + verified + optional premium
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_android_outlined,
                  size: 13,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: _orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _orange,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  size: 14,
                  color: Color(0xFF1976D2),
                ),
                if (isPremium) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💎', style: TextStyle(fontSize: 9)),
                        SizedBox(width: 2),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Numerology stats row
            if (hasNumerology) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (sum != null) ...[
                    Flexible(flex: 2,child: _StatBadge(label: 'SUM', value: '$sum')),
                    const SizedBox(width: 4),
                  ],
                  if (trap != null) ...[
                    Flexible(flex: 2,child: _StatBadge(label: 'TRAP', value: '$trap')),
                    const SizedBox(width: 4),
                  ],
                  if (score != null) ...[
                    Flexible(flex: 2,child: _StatBadge(label: 'SCORE', value: '$score')),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 26,
                      child: OutlinedButton(
                        onPressed: onSimilar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _orange,
                          side: const BorderSide(color: _orange),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'SIMILAR',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: _orange
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Price
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: '₹',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: _formatPrice(displayPrice),
                      style: const TextStyle(
                        color: _orange,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    /*return Card(
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
            ],
          ),
        ),
      ),
    );*/
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

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFDEEAFF),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
