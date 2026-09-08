import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/src/corporate_pack/domain/entities/corporate_pack.dart';
import 'package:numberwale/src/corporate_pack/presentation/bloc/corporate_pack_bloc.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

const _orange = Color(0xFFFF8401);
const _cardBorder = Color(0xFFFFD0A0);
const _sumBadgeBg = Color(0xFFDCEBFF);
const _sumBadgeFg = Color(0xFF1565C0);
const _trapBadgeBg = Color(0xFFFFF1CC);
const _trapBadgeFg = Color(0xFFB8860B);
const _scoreBadgeBg = Color(0xFFDDF5E2);
const _scoreBadgeFg = Color(0xFF2E7D32);

/// The "Type" filter options shown above the pack list, mapped to the
/// `matchType` query param accepted by `GET /api/v1/family-packs/with-products`.
const _typeOptions = [
  (label: 'Numbers in Series', matchType: 'Series'),
  (label: 'All Mixed', matchType: 'All'),
  (label: 'Similar Start', matchType: 'Prefix'),
];

const _sizeOptions = [2, 3, 4, 5, 6, 7, 8, 9];

/// Home screen "Corporate Elite Pack (Jodi)" section - mirrors the web
/// counterpart: a premium-collection badge, type/size filters, a horizontally
/// scrollable list of pack cards (fetched from the family-packs API), and a
/// "Show More" reveal button.
class CorporateElitePackSection extends StatefulWidget {
  const CorporateElitePackSection({super.key});

  @override
  State<CorporateElitePackSection> createState() =>
      _CorporateElitePackSectionState();
}

class _CorporateElitePackSectionState extends State<CorporateElitePackSection> {
  late final CorporatePackBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<CorporatePackBloc>()
      ..add(LoadCorporatePacksEvent(
        matchType: _typeOptions.first.matchType,
        packSize: _sizeOptions.first,
      ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const _PremiumBadge(),
            const SizedBox(height: 14),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Corporate Elite Pack ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextSpan(
                    text: '(Jodi)',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: _orange,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Buy identical, high-value numbers for your entire business '
              'team in a single pack.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<CorporatePackBloc, CorporatePackState>(
              builder: (context, state) {
                final matchType = state is CorporatePackLoaded
                    ? state.matchType
                    : _typeOptions.first.matchType;
                final packSize = state is CorporatePackLoaded
                    ? state.packSize
                    : _sizeOptions.first;

                return _FilterBox(
                  selectedMatchType: matchType,
                  selectedPackSize: packSize,
                  onTypeSelected: (matchType) => _bloc.add(
                    LoadCorporatePacksEvent(
                        matchType: matchType, packSize: packSize),
                  ),
                  onSizeSelected: (size) => _bloc.add(
                    LoadCorporatePacksEvent(
                        matchType: matchType, packSize: size),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<CorporatePackBloc, CorporatePackState>(
              builder: (context, state) {
                if (state is CorporatePackLoading ||
                    state is CorporatePackInitial) {
                  return const SizedBox(
                    height: 380,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is CorporatePackError) {
                  return SizedBox(
                    height: 380,
                    child: Center(
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                final loaded = state as CorporatePackLoaded;
                if (loaded.packs.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No packs available for this selection.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 380,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: loaded.visiblePacks.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return _PackCard(pack: loaded.visiblePacks[index]);
                        },
                      ),
                    ),
                    if (loaded.hasMore) ...[
                      const SizedBox(height: 20),
                      _ShowMoreButton(
                        remainingCount: loaded.remainingCount,
                        onTap: () =>
                            _bloc.add(const ShowMoreCorporatePacksEvent()),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9D6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 13, color: _orange),
          SizedBox(width: 6),
          Text(
            'PREMIUM COLLECTION',
            style: TextStyle(
              color: _orange,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.auto_awesome, size: 13, color: _orange),
        ],
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({
    required this.selectedMatchType,
    required this.selectedPackSize,
    required this.onTypeSelected,
    required this.onSizeSelected,
  });

  final String selectedMatchType;
  final int selectedPackSize;
  final ValueChanged<String> onTypeSelected;
  final ValueChanged<int> onSizeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterRow(
            label: 'TYPE',
            child: Row(
              children: [
                for (final option in _typeOptions) ...[
                  _ChoiceChip(
                    label: option.label,
                    isSelected: option.matchType == selectedMatchType,
                    selectedColor: _orange,
                    onTap: () => onTypeSelected(option.matchType),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FilterRow(
            label: 'SIZE',
            child: Row(
              children: [
                for (final size in _sizeOptions) ...[
                  _ChoiceChip(
                    label: '$size',
                    isSelected: size == selectedPackSize,
                    selectedColor: const Color(0xFF1A1A2E),
                    isSquare: true,
                    onTap: () => onSizeSelected(size),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
    this.isSquare = false,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final bool isSquare;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(isSquare ? 10 : 24),
      onTap: onTap,
      child: Container(
        constraints: isSquare
            ? const BoxConstraints(minWidth: 40, minHeight: 40)
            : const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: isSquare ? 10 : 18),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(isSquare ? 10 : 24),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isSquare ? 14 : 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack});

  final CorporatePack pack;

  String _formatCurrency(double value) {
    final whole = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return '₹$buffer';
  }

  void _copyPackNumbers(BuildContext context) {
    final numbers = pack.products.map((p) => p.number).join(', ');
    Clipboard.setData(ClipboardData(text: numbers));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pack numbers copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(FontAwesomeIcons.crown,
                      color: Colors.white, size: 15),
                ),
                const SizedBox(width: 8),
                _IconSquareButton(
                    icon: Icons.shopping_cart_outlined, onTap: () {}),
                const SizedBox(width: 8),
                _IconSquareButton(icon: Icons.favorite_border, onTap: () {}),
                const Spacer(),
                _IconSquareButton(
                  icon: Icons.copy_outlined,
                  onTap: () => _copyPackNumbers(context),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _orange,
                    side: const BorderSide(color: _orange),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: pack.products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _PackNumberRow(number: pack.products[index]),
              ),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PACK SIZE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${pack.packSize} Numbers',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL VALUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(pack.totalValue),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: _orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: const Color(0xFF4B5563)),
      ),
    );
  }
}

class _PackNumberRow extends StatelessWidget {
  const _PackNumberRow({required this.number});

  final PhoneNumber number;

  String _formatCurrency(double value) {
    final whole = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return '₹$buffer';
  }

  @override
  Widget build(BuildContext context) {
    final digits = number.number;
    final lastDigits = digits.length > 1 ? digits.substring(digits.length - 1) : digits;
    final leadDigits = digits.length > 1 ? digits.substring(0, digits.length - 1) : '';

    final sum = (number.numerology?['liters'] ?? number.numerology?['sum']) as int?;
    final trap = number.numerology?['trap'] as int?;
    final score = number.numerology?['score'] as int?;
    final hasStats = sum != null || trap != null || score != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: _orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 13, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: leadDigits,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    TextSpan(
                      text: lastDigits,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _orange,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _formatCurrency(number.discountedPrice),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
        if (hasStats) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                if (sum != null) _StatBadge(label: 'SUM', value: '$sum', bg: _sumBadgeBg, fg: _sumBadgeFg),
                if (sum != null) const SizedBox(width: 6),
                if (trap != null) _StatBadge(label: 'TRAP', value: '$trap', bg: _trapBadgeBg, fg: _trapBadgeFg),
                if (trap != null) const SizedBox(width: 6),
                if (score != null) _StatBadge(label: 'SCORE', value: '$score', bg: _scoreBadgeBg, fg: _scoreBadgeFg),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  final String label;
  final String value;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShowMoreButton extends StatelessWidget {
  const _ShowMoreButton({required this.remainingCount, required this.onTap});

  final int remainingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _orange,
        side: const BorderSide(color: _orange),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'Show More ($remainingCount pack${remainingCount == 1 ? '' : 's'} left)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.auto_awesome, size: 14, color: _orange),
        ],
      ),
    );
  }
}
