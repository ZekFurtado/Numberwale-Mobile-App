import 'package:flutter/material.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    super.key,
    required this.subtotal,
    this.discount = 0,
    this.cgst,
    this.sgst,
  });

  final double subtotal;
  final double discount;
  final double? cgst;
  final double? sgst;

  double get _gstRate => 0.18; // 18% GST

  double get _discountAmount => (subtotal * discount) / 100;

  double get _subtotalAfterDiscount => subtotal - _discountAmount;

  double get _cgstAmount => cgst ?? (_subtotalAfterDiscount * _gstRate / 2);

  double get _sgstAmount => sgst ?? (_subtotalAfterDiscount * _gstRate / 2);

  double get _totalGst => _cgstAmount + _sgstAmount;

  double get _grandTotal => _subtotalAfterDiscount + _totalGst;

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)}L';
    } else if (price >= 1000) {
      return '₹${(price / 1000).toStringAsFixed(2)}K';
    }
    return '₹${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Price Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Subtotal
            _SummaryRow(
              label: 'Subtotal',
              value: _formatPrice(subtotal),
              theme: theme,
            ),

            const SizedBox(height: 12),

            // Discount (if applicable)
            if (discount > 0) ...[
              _SummaryRow(
                label: 'Discount ($discount%)',
                value: '- ${_formatPrice(_discountAmount)}',
                theme: theme,
                valueColor: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 12),
            ],

            // Subtotal after discount (if discount applied)
            if (discount > 0) ...[
              _SummaryRow(
                label: 'After Discount',
                value: _formatPrice(_subtotalAfterDiscount),
                theme: theme,
              ),
              const SizedBox(height: 12),
            ],

            const Divider(),
            const SizedBox(height: 12),

            // CGST
            _SummaryRow(
              label: 'CGST (9%)',
              value: _formatPrice(_cgstAmount),
              theme: theme,
            ),

            const SizedBox(height: 8),

            // SGST
            _SummaryRow(
              label: 'SGST (9%)',
              value: _formatPrice(_sgstAmount),
              theme: theme,
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Grand Total
            _SummaryRow(
              label: 'Total Amount',
              value: _formatPrice(_grandTotal),
              theme: theme,
              isBold: true,
              valueColor: theme.colorScheme.primary,
              fontSize: 20,
            ),

            const SizedBox(height: 16),

            // Tax info note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'GST (18%) is calculated as per government regulations',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isBold = false,
    this.valueColor,
    this.fontSize,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool isBold;
  final Color? valueColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : theme.colorScheme.onSurfaceVariant,
            fontSize: fontSize,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
