import 'package:flutter/material.dart';
import 'package:numberwale/core/models/filter_models.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({
    super.key,
    required this.currentSort,
  });

  final SortOption currentSort;

  static Future<SortOption?> show(
    BuildContext context, {
    required SortOption currentSort,
  }) {
    return showModalBottomSheet<SortOption>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SortBottomSheet(currentSort: currentSort),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Sort By',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),

          // Sort options
          ...SortOption.values.map((option) {
            final isSelected = option == currentSort;
            return ListTile(
              leading: Icon(
                _getIconForSortOption(option),
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                option.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    )
                  : null,
              onTap: () {
                Navigator.pop(context, option);
              },
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getIconForSortOption(SortOption option) {
    switch (option) {
      case SortOption.priceLowToHigh:
        return Icons.trending_down;
      case SortOption.priceHighToLow:
        return Icons.trending_up;
      case SortOption.newest:
        return Icons.new_releases;
      case SortOption.popular:
        return Icons.local_fire_department;
      case SortOption.featured:
        return Icons.star;
    }
  }
}
