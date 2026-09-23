import 'package:flutter/material.dart';
import 'package:numberwale/core/widgets/premium_number_card.dart';

const _removeBg = Color(0xFFFDECEC);
const _removeRed = Color(0xFFE5484D);

/// Cart item card mirroring numberwale.com's shopping-cart line item — the
/// shared [PremiumNumberCard] shell with a full-width remove action.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.phoneNumber,
    required this.price,
    this.category,
    this.numerology,
    required this.onRemove,
    required this.onTap,
  });

  final String phoneNumber;
  final double price;
  final String? category;
  final Map<String, dynamic>? numerology;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumNumberCard(
      phoneNumber: phoneNumber,
      price: price,
      category: category,
      numerology: numerology,
      onTap: onTap,
      actions: SizedBox(
        width: double.infinity,
        height: 44,
        child: TextButton.icon(
          onPressed: onRemove,
          style: TextButton.styleFrom(
            backgroundColor: _removeBg,
            foregroundColor: _removeRed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Remove Item', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
