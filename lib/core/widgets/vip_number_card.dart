import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/fancy_number_spans.dart';
import 'package:numberwale/core/utils/product_actions.dart';

const _orange = Color(0xFFFF8401);
const _cardBorder = Color(0xFFFFD9B3);
const _pillCream = Color(0xFFFFF7ED);
const _sumBlue = Color(0xFF3B82F6);
const _trapAmber = Color(0xFFE0A62E);
const _scorePurple = Color(0xFF8B5CF6);
const _saveBlue = Color(0xFF2F80ED);
const _timerRed = Color(0xFFE5484D);
const _enquireDark = Color(0xFF2D3748);

/// Large single-column card used for the "Newly Added VIP Numbers" section:
/// a phone icon, the number in a bold orange pill (with its fancy pattern
/// highlighted in white), a verified badge, category + numerology stat
/// pills, the price, and a wishlist / Buy Now / add-to-cart action row.
class VipNumberCard extends StatelessWidget {
  const VipNumberCard({
    super.key,
    required this.phoneNumber,
    required this.price,
    required this.category,
    this.numerology,
    this.isWishlisted = false,
    this.operatorProvider,
    this.operatorState,
    this.originalPrice,
    this.discount,
    this.dealEndsAt,
    this.onTap,
    this.onAddToCart,
    this.onBuyNow,
    this.onEnquire,
    this.onWishlist,
  });

  final String phoneNumber;
  final double price;
  final String category;
  final Map<String, dynamic>? numerology;
  final bool isWishlisted;

  /// Telecom operator (Jio, Airtel, VI) and home state, shown as a badge row
  /// when both are provided (5-min activation numbers).
  final String? operatorProvider;
  final String? operatorState;

  /// Pre-discount price. Shown struck-through next to [price] and used with
  /// [discount] to render the "Save X%" badge, when both are set.
  final double? originalPrice;

  /// Discount percentage (0-100).
  final int? discount;

  /// When set, renders a live countdown ("4D 00H 38M 51S") to this deadline.
  final DateTime? dealEndsAt;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  /// Adds the number to the cart and continues to checkout.
  final VoidCallback? onBuyNow;

  /// Opens the enquiry form. Used instead of [onBuyNow] for numbers priced
  /// above the online-purchase limit.
  final VoidCallback? onEnquire;
  final VoidCallback? onWishlist;

  @override
  Widget build(BuildContext context) {
    final sum = (numerology?['liters'] ?? numerology?['sum']) as int?;
    final trap = numerology?['trap'] as int?;
    final score = numerology?['score'] as int?;
    final hasNumerology = sum != null || trap != null || score != null;
    final hasDiscount = originalPrice != null && (discount ?? 0) > 0;
    // Numbers over ₹5 lakh including GST are enquiry-only.
    final isEnquiryOnly = ProductActions.isEnquiryOnly(price);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _cardBorder, width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const _CircleIconButton(
                  icon: Icons.phone_android_outlined,
                  iconColor: Color(0xFF6B7280),
                ),
                const SizedBox(width: 10),
                Expanded(child: _NumberPill(number: phoneNumber)),
                const SizedBox(width: 10),
                const _CircleIconButton(
                  icon: Icons.verified,
                  iconColor: Color(0xFF1976D2),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category.isNotEmpty) _CategoryBadge(label: category),
                if (hasNumerology)
                  _StatsPill(sum: sum, trap: trap, score: score),
              ],
            ),
            const SizedBox(height: 14),
            hasDiscount
                ? _DiscountPriceRow(
                    originalPrice: originalPrice!,
                    price: price,
                    discount: discount!,
                  )
                : _PriceText(price: price),
            if (operatorProvider != null && operatorState != null) ...[
              const SizedBox(height: 10),
              _OperatorRow(
                provider: operatorProvider!,
                state: operatorState!,
              ),
            ],
            if (dealEndsAt != null) ...[
              const SizedBox(height: 10),
              _CountdownPill(endsAt: dealEndsAt!),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _SquareIconButton(
                  icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
                  onTap: onWishlist,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: isEnquiryOnly
                        ? ElevatedButton.icon(
                            onPressed: onEnquire ?? onTap,
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text(
                              'Enquire Now',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _enquireDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: onBuyNow ?? onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _orange,
                              backgroundColor: _pillCream,
                              side: const BorderSide(color: _orange, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                ),
                if (!isEnquiryOnly) ...[
                  const SizedBox(width: 10),
                  _SquareIconButton(
                    icon: Icons.shopping_cart_outlined,
                    onTap: onAddToCart,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.iconColor});

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, size: 18, color: iconColor),
    );
  }
}

class _NumberPill extends StatelessWidget {
  const _NumberPill({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(27),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: RichText(
          text: TextSpan(
            children: buildFancyNumberSpans(
              number,
              plainStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.3,
              ),
              highlightStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _pillCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orange),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: _orange,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatsPill extends StatelessWidget {
  const _StatsPill({this.sum, this.trap, this.score});

  final int? sum;
  final int? trap;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final stats = [
      if (sum != null) ('SUM', sum!, _sumBlue),
      if (trap != null) ('TRAP', trap!, _trapAmber),
      if (score != null) ('SCORE', score!, _scorePurple),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(width: 8),
              Container(width: 1, height: 12, color: const Color(0xFFD1D5DB)),
              const SizedBox(width: 8),
            ],
            _StatValue(
              label: stats[i].$1,
              value: stats[i].$2,
              color: stats[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '$value',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  const _PriceText({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: '₹',
            style: TextStyle(
              color: _orange,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: price.round().toString(),
            style: const TextStyle(
              color: _orange,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountPriceRow extends StatelessWidget {
  const _DiscountPriceRow({
    required this.originalPrice,
    required this.price,
    required this.discount,
  });

  final double originalPrice;
  final double price;
  final int discount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text(
          '₹${originalPrice.round()}',
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        _PriceText(price: price),
        _SaveBadge(percent: discount),
      ],
    );
  }
}

class _SaveBadge extends StatelessWidget {
  const _SaveBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _saveBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Save $percent%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Live countdown pill ("4D 00H 38M 51S") ticking down to [endsAt] every
/// second. Hides itself once the deadline has passed.
class _CountdownPill extends StatefulWidget {
  const _CountdownPill({required this.endsAt});

  final DateTime endsAt;

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endsAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = widget.endsAt.difference(DateTime.now());
      if (!mounted) return;
      setState(() => _remaining = next.isNegative ? Duration.zero : next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '${days}D '
        '${hours.toString().padLeft(2, '0')}H '
        '${minutes.toString().padLeft(2, '0')}M '
        '${seconds.toString().padLeft(2, '0')}S';
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= Duration.zero) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _timerRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_filled, color: Colors.white, size: 13),
          const SizedBox(width: 6),
          Text(
            _format(_remaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

const _operatorColors = {
  'jio': Color(0xFF0A2885),
  'airtel': Color(0xFFED1C24),
  'vi': Color(0xFFEE0A24),
  'vodafone': Color(0xFFEE0A24),
  'idea': Color(0xFFEE0A24),
  'bsnl': Color(0xFF004C97),
};

class _OperatorRow extends StatelessWidget {
  const _OperatorRow({required this.provider, required this.state});

  final String provider;
  final String state;

  @override
  Widget build(BuildContext context) {
    final color = _operatorColors[provider.toLowerCase()] ?? _orange;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            provider.isNotEmpty ? provider[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 13, color: _orange),
              const SizedBox(width: 4),
              Text(
                state,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pillCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _orange.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: _orange, size: 20),
      ),
    );
  }
}
