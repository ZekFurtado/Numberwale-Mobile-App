import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberwale/core/models/filter_models.dart';
import 'package:numberwale/core/widgets/sort_bottom_sheet.dart';
import 'package:numberwale/src/products/domain/entities/advanced_search_filters.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';

/// Advanced Search page, replicating the web's Advanced Search filter
/// builder for the Explore Numbers grid.
class AdvancedSearchPage extends StatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final _startsWithController = TextEditingController();
  final _anywhereController = TextEditingController();
  final _endsWithController = TextEditingController();
  final _mustContainController = TextEditingController();
  final _notContainController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _digitController = TextEditingController();
  final _minCountController = TextEditingController();
  final _literSumController = TextEditingController();
  final _trapSumController = TextEditingController();
  final _scoreSumController = TextEditingController();

  final List<String?> _exactDigits = List<String?>.filled(10, null);
  SortOption _sortBy = SortOption.featured;

  @override
  void dispose() {
    _startsWithController.dispose();
    _anywhereController.dispose();
    _endsWithController.dispose();
    _mustContainController.dispose();
    _notContainController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _digitController.dispose();
    _minCountController.dispose();
    _literSumController.dispose();
    _trapSumController.dispose();
    _scoreSumController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      for (final controller in [
        _startsWithController,
        _anywhereController,
        _endsWithController,
        _mustContainController,
        _notContainController,
        _minPriceController,
        _maxPriceController,
        _digitController,
        _minCountController,
        _literSumController,
        _trapSumController,
        _scoreSumController,
      ]) {
        controller.clear();
      }
      _exactDigits.fillRange(0, _exactDigits.length, null);
      _sortBy = SortOption.featured;
    });
  }

  void _clearExactDigits() {
    setState(() => _exactDigits.fillRange(0, _exactDigits.length, null));
  }

  Future<void> _openSortSheet() async {
    final result = await SortBottomSheet.show(context, currentSort: _sortBy);
    if (result != null) setState(() => _sortBy = result);
  }

  void _applyQuickTemplate(_QuickTemplate template) {
    setState(() {
      switch (template) {
        case _QuickTemplate.lucky79:
          _mustContainController.text = '79';
          break;
        case _QuickTemplate.prosperity5:
          _mustContainController.text = '5';
          break;
        case _QuickTemplate.no4s:
          _notContainController.text = '4';
          break;
        case _QuickTemplate.budget1kTo10k:
          _minPriceController.text = '1000';
          _maxPriceController.text = '10000';
          break;
      }
    });
  }

  int? _parseInt(String text) => text.isEmpty ? null : int.tryParse(text);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  ProductFilters? _buildFilters() {
    final minPrice = _parseInt(_minPriceController.text)?.toDouble();
    final maxPrice = _parseInt(_maxPriceController.text)?.toDouble();

    if (minPrice != null && maxPrice != null && minPrice >= maxPrice) {
      _showError('Minimum price must be less than maximum price');
      return null;
    }
    if ((maxPrice ?? 0) > 1000000) {
      _showError('Maximum price cannot exceed ₹10,00,000');
      return null;
    }

    String? exactDigitPlacement;
    if (_exactDigits.any((d) => d != null && d.isNotEmpty)) {
      exactDigitPlacement = _exactDigits.map((d) => (d == null || d.isEmpty) ? '?' : d).join();
    }

    final digit = _digitController.text;
    final minCount = _parseInt(_minCountController.text);

    final advanced = AdvancedSearchFilters(
      startsWith: _startsWithController.text.isEmpty ? null : _startsWithController.text,
      endsWith: _endsWithController.text.isEmpty ? null : _endsWithController.text,
      anywhere: _anywhereController.text.isEmpty ? null : _anywhereController.text,
      mustContain: _mustContainController.text.isEmpty ? null : _mustContainController.text,
      notContain: _notContainController.text.isEmpty ? null : _notContainController.text,
      literSum: _parseInt(_literSumController.text),
      trapSum: _parseInt(_trapSumController.text),
      scoreSum: _parseInt(_scoreSumController.text),
      exactDigitPlacement: exactDigitPlacement,
      mostContainDigit: digit.isEmpty ? null : digit,
      mostContainCount: minCount?.clamp(1, 10),
    );

    String? sortPrice;
    if (_sortBy == SortOption.priceLowToHigh) {
      sortPrice = 'lowToHigh';
    } else if (_sortBy == SortOption.priceHighToLow) {
      sortPrice = 'highToLow';
    }

    return ProductFilters(
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortPrice: sortPrice,
      advanced: advanced.isEmpty ? null : advanced,
    );
  }

  void _search() {
    final filters = _buildFilters();
    if (filters == null) return;

    // AdvancedSearchPage is always pushed via Navigator on top of a screen
    // that already has a valid ProductBloc in context (Explore Numbers or
    // the shell app bar, both descendants of AppShell's BlocProvider) —
    // pushed routes are separate Navigator/Overlay entries and are NOT
    // descendants of the page that pushed them, so this page can't reach
    // that ProductBloc itself. Hand the built filters back to the caller
    // instead, same as FilterBottomSheet/SortBottomSheet already do.
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SortControl(sortBy: _sortBy, onTap: _openSortSheet),
                const SizedBox(height: 16),
                _QuickTemplatesRow(onSelected: _applyQuickTemplate),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.filter_alt,
                  title: 'Pattern Search',
                  children: [
                    _LabeledField(
                      label: 'Starts With',
                      controller: _startsWithController,
                      hint: 'e.g., 123',
                      helper: 'Enter digits that the number must start with',
                    ),
                    _LabeledField(
                      label: 'Anywhere',
                      controller: _anywhereController,
                      hint: 'e.g., 567',
                      helper: 'Enter digits that must appear anywhere in the number',
                    ),
                    _LabeledField(
                      label: 'Ends With',
                      controller: _endsWithController,
                      hint: 'e.g., 789',
                      helper: 'Enter digits that the number must end with',
                    ),
                    _LabeledField(
                      label: 'Must Contain',
                      controller: _mustContainController,
                      hint: 'e.g., 4,5,7 (max 5 digits)',
                      helper: 'Enter up to 5 digits that must appear (comma-separated)',
                      digitsOnly: false,
                    ),
                    _LabeledField(
                      label: 'Must Not Contain',
                      controller: _notContainController,
                      hint: 'e.g., 000, 666, 13 (max 5 digits)',
                      helper: 'Enter up to 5 digits to exclude (comma-separated)',
                      digitsOnly: false,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.currency_rupee,
                  title: 'Price Range',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Minimum Price',
                            controller: _minPriceController,
                            hint: '1000',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Maximum Price',
                            controller: _maxPriceController,
                            hint: '50000',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.swap_vert,
                  title: 'Digit Frequency',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Digit',
                            controller: _digitController,
                            hint: '0-9',
                            helper: 'Which digit to count',
                            maxLength: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Min Count',
                            controller: _minCountController,
                            hint: '1-10',
                            helper: 'Min appears',
                            maxLength: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.calculate,
                  title: 'Numerical Analysis',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Liter Sum',
                            controller: _literSumController,
                            hint: '56',
                            helper: 'Sum of all digits',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Mid Sum',
                            controller: _trapSumController,
                            hint: '11',
                            helper: 'Special calculation',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Score Sum',
                            controller: _scoreSumController,
                            hint: '2',
                            helper: 'Numerological score',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.tag,
                  title: 'Exact Digit Placement',
                  trailing: TextButton(
                    onPressed: _clearExactDigits,
                    child: const Text('Clear All'),
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(10, (index) {
                        return SizedBox(
                          width: 28,
                          child: TextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                            decoration: InputDecoration(
                              hintText: '?',
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              _exactDigits[index] = value.isEmpty ? null : value;
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter specific digits at exact positions or leave blank (?) for any digit',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _search,
                  child: const Text('Search'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _QuickTemplate { lucky79, prosperity5, no4s, budget1kTo10k }

class _SortControl extends StatelessWidget {
  const _SortControl({required this.sortBy, required this.onTap});

  final SortOption sortBy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.swap_vert),
      label: Text('Sort: ${sortBy.label}'),
    );
  }
}

class _QuickTemplatesRow extends StatelessWidget {
  const _QuickTemplatesRow({required this.onSelected});

  final ValueChanged<_QuickTemplate> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.search, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Quick Templates',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickTemplateChip(
              emoji: '🍀',
              label: 'Lucky 79',
              backgroundColor: const Color(0xFFFDE68A),
              borderColor: const Color(0xFFE8B92C),
              textColor: const Color(0xFF6B4A00),
              onTap: () => onSelected(_QuickTemplate.lucky79),
            ),
            _QuickTemplateChip(
              emoji: '💰',
              label: 'Prosperity 5',
              backgroundColor: const Color(0xFFA7F3D0),
              borderColor: const Color(0xFF4CAF82),
              textColor: const Color(0xFF166534),
              onTap: () => onSelected(_QuickTemplate.prosperity5),
            ),
            _QuickTemplateChip(
              emoji: '🚫',
              label: "No 4's",
              backgroundColor: const Color(0xFFFECACA),
              borderColor: const Color(0xFFE57373),
              textColor: const Color(0xFF8B1A1A),
              onTap: () => onSelected(_QuickTemplate.no4s),
            ),
            _QuickTemplateChip(
              emoji: '💎',
              label: '₹1K-10K',
              backgroundColor: const Color(0xFFDDD6FE),
              borderColor: const Color(0xFF9B7FD4),
              textColor: const Color(0xFF5B3FA0),
              onTap: () => onSelected(_QuickTemplate.budget1kTo10k),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickTemplateChip extends StatelessWidget {
  const _QuickTemplateChip({
    required this.emoji,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ?trailing,
              ],
            ),
            const Divider(height: 24),
            ...children.expand((child) => [child, const SizedBox(height: 12)]),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.helper,
    this.digitsOnly = true,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? helper;
  final bool digitsOnly;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
              if (!digitsOnly) FilteringTextInputFormatter.allow(RegExp(r'[0-9,\s]')),
              if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
