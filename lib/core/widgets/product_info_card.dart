import 'package:flutter/material.dart';

class ProductInfoCard extends StatelessWidget {
  const ProductInfoCard({
    super.key,
    required this.operator,
    required this.category,
    this.rtp,
    this.availability = 'Available',
    this.features = const [],
  });

  final String operator;
  final String category;
  final String? rtp;
  final String availability;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
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
              'Product Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Details grid
            _InfoGridItem(
              icon: Icons.sim_card,
              label: 'Operator',
              value: operator,
              theme: theme,
            ),
            const SizedBox(height: 16),

            _InfoGridItem(
              icon: Icons.category,
              label: 'Category',
              value: category,
              theme: theme,
            ),
            const SizedBox(height: 16),

            if (rtp != null) ...[
              _InfoGridItem(
                icon: Icons.compare_arrows,
                label: 'RTP (Porting)',
                value: rtp!,
                theme: theme,
              ),
              const SizedBox(height: 16),
            ],

            _InfoGridItem(
              icon: Icons.check_circle,
              label: 'Availability',
              value: availability,
              theme: theme,
              valueColor: availability.toLowerCase() == 'available'
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.error,
            ),

            // Features section
            if (features.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((feature) {
                  return Chip(
                    label: Text(feature),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoGridItem extends StatelessWidget {
  const _InfoGridItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
