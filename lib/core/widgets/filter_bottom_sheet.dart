import 'package:flutter/material.dart';
import 'package:numberwale/core/models/filter_models.dart';
import 'package:numberwale/core/widgets/category_filter_chip.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
  });

  final NumberFilters initialFilters;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static Future<NumberFilters?> show(
    BuildContext context, {
    required NumberFilters initialFilters,
  }) {
    return showModalBottomSheet<NumberFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(initialFilters: initialFilters),
    );
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late NumberFilters _filters;
  late RangeValues _priceRange;

  final List<String> _availableFeatures = [
    'Easy to Remember',
    'Sequential',
    'Repeating',
    'Mirror',
    'Premium',
    'Lucky',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceRange = RangeValues(
      _filters.priceRange.min,
      _filters.priceRange.max,
    );
  }

  void _applyFilters() {
    Navigator.pop(context, _filters);
  }

  void _resetFilters() {
    setState(() {
      _filters = _filters.reset();
      _priceRange = const RangeValues(0, 1000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Category Section
                  Text(
                    'Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: NumberCategory.values.map((category) {
                      return CategoryFilterChip(
                        label: category.label,
                        isSelected: _filters.category == category,
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(category: category);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Price Range Section
                  Text(
                    'Price Range',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${(_priceRange.start / 1000).toStringAsFixed(0)}K',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _priceRange.end >= 1000000
                            ? '₹${(_priceRange.end / 100000).toStringAsFixed(0)}L+'
                            : '₹${(_priceRange.end / 1000).toStringAsFixed(0)}K',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    labels: RangeLabels(
                      '₹${(_priceRange.start / 1000).toStringAsFixed(0)}K',
                      _priceRange.end >= 1000000
                          ? '₹${(_priceRange.end / 100000).toStringAsFixed(0)}L+'
                          : '₹${(_priceRange.end / 1000).toStringAsFixed(0)}K',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                        _filters = _filters.copyWith(
                          priceRange: PriceRange(
                            min: values.start,
                            max: values.end,
                          ),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Quick price filters
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PriceFilterChip(
                        label: 'Under ₹10K',
                        range: PriceRange.under10k,
                        isSelected: _filters.priceRange == PriceRange.under10k,
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(
                              priceRange: PriceRange.under10k,
                            );
                            _priceRange = RangeValues(
                              PriceRange.under10k.min,
                              PriceRange.under10k.max,
                            );
                          });
                        },
                      ),
                      _PriceFilterChip(
                        label: '₹10K - ₹25K',
                        range: PriceRange.range10kTo25k,
                        isSelected:
                            _filters.priceRange == PriceRange.range10kTo25k,
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(
                              priceRange: PriceRange.range10kTo25k,
                            );
                            _priceRange = RangeValues(
                              PriceRange.range10kTo25k.min,
                              PriceRange.range10kTo25k.max,
                            );
                          });
                        },
                      ),
                      _PriceFilterChip(
                        label: '₹25K - ₹50K',
                        range: PriceRange.range25kTo50k,
                        isSelected:
                            _filters.priceRange == PriceRange.range25kTo50k,
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(
                              priceRange: PriceRange.range25kTo50k,
                            );
                            _priceRange = RangeValues(
                              PriceRange.range25kTo50k.min,
                              PriceRange.range25kTo50k.max,
                            );
                          });
                        },
                      ),
                      _PriceFilterChip(
                        label: 'Above ₹100K',
                        range: PriceRange.above100k,
                        isSelected: _filters.priceRange == PriceRange.above100k,
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(
                              priceRange: PriceRange.above100k,
                            );
                            _priceRange = RangeValues(
                              PriceRange.above100k.min,
                              PriceRange.above100k.max,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Features Section
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
                    children: _availableFeatures.map((feature) {
                      final isSelected = _filters.features.contains(feature);
                      return CategoryFilterChip(
                        label: feature,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            final features = List<String>.from(_filters.features);
                            if (isSelected) {
                              features.remove(feature);
                            } else {
                              features.add(feature);
                            }
                            _filters = _filters.copyWith(features: features);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Other Filters
                  CheckboxListTile(
                    value: _filters.onlyDiscounted,
                    onChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(
                          onlyDiscounted: value ?? false,
                        );
                      });
                    },
                    title: Text(
                      'Show only discounted numbers',
                      style: theme.textTheme.bodyMedium,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Apply Button (Fixed at bottom)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PriceFilterChip extends StatelessWidget {
  const _PriceFilterChip({
    required this.label,
    required this.range,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final PriceRange range;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CategoryFilterChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}
