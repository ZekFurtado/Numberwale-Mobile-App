import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/fancy_number_spans.dart';

const kPremiumCardOrange = Color(0xFFFF8401);
const kPremiumCardBorder = Color(0xFFFFD9B3);
const kPremiumCardCream = Color(0xFFFFF7ED);
const kPremiumCardSumBlue = Color(0xFF3B82F6);
const kPremiumCardScorePurple = Color(0xFF8B5CF6);

/// Shared "premium number" card shell — a phone icon, the number in a bold
/// orange pill, a badge slot on the right (a verified check by default),
/// category + numerology stat pills, the price, and a caller-supplied
/// actions area. Used by the cart ([CartItemCard]) and the wishlist so both
/// present numbers identically.
class PremiumNumberCard extends StatelessWidget {
  const PremiumNumberCard({
    super.key,
    required this.phoneNumber,
    required this.price,
    this.category,
    this.numerology,
    this.trailing,
    required this.actions,
    this.onTap,
  });

  final String phoneNumber;
  final double price;
  final String? category;
  final Map<String, dynamic>? numerology;

  /// The small circular badge on the right of the number pill. Defaults to
  /// a verified checkmark when omitted.
  final Widget? trailing;

  /// The bottom action area — a single button, a row of them, etc.
  final Widget actions;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sum = (numerology?['liters'] ?? numerology?['sum']) as int?;
    final score = numerology?['score'] as int?;
    final hasNumerology = sum != null || score != null;
    final hasCategory = category != null && category!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kPremiumCardBorder, width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Icon(
                    Icons.phone_android_outlined,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kPremiumCardOrange,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: RichText(
                        text: TextSpan(
                          children: buildFancyNumberSpans(
                            phoneNumber,
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
                  ),
                ),
                const SizedBox(width: 10),
                trailing ?? const _VerifiedBadge(),
              ],
            ),
            if (hasCategory || hasNumerology) ...[
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasCategory) _CategoryBadge(label: category!),
                  if (hasNumerology) _StatsPill(sum: sum, score: score),
                ],
              ),
            ],
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: '₹',
                    style: TextStyle(
                      color: kPremiumCardOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: price.round().toString(),
                    style: const TextStyle(
                      color: kPremiumCardOrange,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            actions,
          ],
        ),
      ),
    );
  }
}

/// A circular badge sized to drop into [PremiumNumberCard.trailing],
/// matching the verified-check slot's footprint (e.g. a wishlist heart
/// toggle in place of the default verified check).
class PremiumCardBadge extends StatelessWidget {
  const PremiumCardBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
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

    if (onTap == null) return badge;

    final button = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: badge,
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return const PremiumCardBadge(icon: Icons.verified, iconColor: Color(0xFF1976D2));
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
        color: kPremiumCardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPremiumCardOrange),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: kPremiumCardOrange,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatsPill extends StatelessWidget {
  const _StatsPill({this.sum, this.score});

  final int? sum;
  final int? score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sum != null) _StatValue(label: 'SUM', value: sum!, color: kPremiumCardSumBlue),
          if (sum != null && score != null) ...[
            const SizedBox(width: 8),
            Container(width: 1, height: 12, color: const Color(0xFFD1D5DB)),
            const SizedBox(width: 8),
          ],
          if (score != null) _StatValue(label: 'SCORE', value: score!, color: kPremiumCardScorePurple),
        ],
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({required this.label, required this.value, required this.color});

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
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
