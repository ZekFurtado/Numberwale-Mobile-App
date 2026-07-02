import 'package:flutter/material.dart';

const _orange = Color(0xFFFF8401);
const _cardBg = Color(0xFFFFFFFF);
// const _cardBg = Color(0xFFFFF8F0);
const _cardBorder = Color(0xFFFFD0A0);
const _enquireDark = Color(0xFF2D3748);

class ProductCard extends StatelessWidget {
  const ProductCard({
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
  final bool isPremium;
  final bool isEnquiry;
  final bool isWishlisted;
  final Map<String, dynamic>? numerology;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onWishlist;
  final VoidCallback? onSimilar;

  String _formatPhoneNumber(String number) {
    if (number.length == 10) {
      return '${number.substring(0, 5)} ${number.substring(5)}';
    }
    return number;
  }

  String _formatPrice(double p) {
    return p.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final sum = (numerology?['liters'] ?? numerology?['sum']) as int?;
    final score = numerology?['score'] as int?;
    final trap = numerology?['trap'] as int?;
    final hasNumerology = sum != null || score != null;
    final hasDiscount = discount != null && discount! > 0;
    final displayPrice = hasDiscount ? price * (1 - discount! / 100) : price;
    final effectiveIsEnquiry = isEnquiry || (price * 1.18 > 500000);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              const SizedBox(height: 8),

              // Action row: heart + Buy Now/Enquire Now + cart
              Row(
                children: [
                  GestureDetector(
                    onTap: onWishlist,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFfff7ed),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: _orange.withAlpha(60)),

                      ),
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: _orange,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: effectiveIsEnquiry
                          ? ElevatedButton.icon(
                              onPressed: onTap,
                              icon: const Icon(Icons.phone, size: 14),
                              label: const Text(
                                'Enquire Now',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _enquireDark,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                          : OutlinedButton(
                              onPressed: onTap,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _orange,
                                backgroundColor: Color(0xfffff7ed),
                                side: const BorderSide(color: _orange),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: _orange.withAlpha(60)),
                        color: Color(0xFFfff7ed),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart_outlined,
                        color: _orange,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
