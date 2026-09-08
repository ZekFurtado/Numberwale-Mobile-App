import 'package:flutter/material.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

const _dealOrange = Color(0xFFFF6A1F);
const _dealNavy = Color(0xFF1A1A2E);
const _cardRadius = 26.0;

/// Home screen "Deal of the Day" section: a horizontally scrollable carousel
/// of discounted numbers where only the centered card is elevated/in-focus
/// while neighbouring cards are faded and scaled down. Tapping
/// "Unlock Target Deal" reveals the discounted price for the centered card
/// with a speedometer-style count-up animation.
class DealOfTheDaySection extends StatefulWidget {
  const DealOfTheDaySection({
    super.key,
    required this.numbers,
    this.onClaim,
  });

  final List<PhoneNumber> numbers;
  final ValueChanged<PhoneNumber>? onClaim;

  @override
  State<DealOfTheDaySection> createState() => _DealOfTheDaySectionState();
}

class _DealOfTheDaySectionState extends State<DealOfTheDaySection> {
  late final PageController _pageController;
  double _page = 0;
  final Set<int> _unlockedIndices = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82)
      ..addListener(() {
        final page = _pageController.page;
        if (page != null) setState(() => _page = page);
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int delta) {
    final current = (_pageController.page ?? _page).round();
    final target = (current + delta).clamp(0, widget.numbers.length - 1);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.numbers.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final centerIndex = _page.round().clamp(0, widget.numbers.length - 1);
    final centerUnlocked = _unlockedIndices.contains(centerIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: _dealOrange, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deal of the Day',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Unlock today\'s exclusive number before the deal ends',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 470,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.numbers.length,
                itemBuilder: (context, index) {
                  final distance = (index - _page).abs().clamp(0.0, 1.0);
                  final scale = 1 - (distance * 0.14);
                  final opacity = (1 - (distance * 0.65)).clamp(0.0, 1.0);
                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: _DealCard(
                          number: widget.numbers[index],
                          isUnlocked: _unlockedIndices.contains(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (widget.numbers.length > 1) ...[
                Align(
                  alignment: const Alignment(-0.94, -0.18),
                  child: _NavArrow(
                    icon: Icons.chevron_left,
                    onTap: () => _goTo(-1),
                  ),
                ),
                Align(
                  alignment: const Alignment(0.94, -0.18),
                  child: _NavArrow(
                    icon: Icons.chevron_right,
                    onTap: () => _goTo(1),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: _DealActionButton(
            isUnlocked: centerUnlocked,
            onUnlock: () => setState(() => _unlockedIndices.add(centerIndex)),
            onClaim: () =>
                widget.onClaim?.call(widget.numbers[centerIndex]),
          ),
        ),
      ],
    );
  }
}

/// Splits [number] into spans, highlighting the longest run of a repeated
/// digit (the number's "special" pattern, e.g. `0000` or `3333`) in orange
/// and grouping digits with a space for readability.
List<InlineSpan> _buildNumberSpans(String number) {
  var bestStart = 0;
  var bestLen = 0;
  var i = 0;
  while (i < number.length) {
    var j = i;
    while (j < number.length && number[j] == number[i]) {
      j++;
    }
    final len = j - i;
    if (len > bestLen) {
      bestLen = len;
      bestStart = i;
    }
    i = j;
  }

  final int hlStart;
  final int hlEnd;
  if (bestLen >= 3) {
    hlStart = bestStart;
    hlEnd = bestStart + bestLen;
  } else {
    hlStart = (number.length - 4).clamp(0, number.length);
    hlEnd = number.length;
  }

  final spans = <InlineSpan>[];
  for (var idx = 0; idx < number.length; idx++) {
    if (idx == 5 && number.length >= 8) {
      spans.add(const TextSpan(text: ' '));
    }
    final highlighted = idx >= hlStart && idx < hlEnd;
    spans.add(TextSpan(
      text: number[idx],
      style: TextStyle(color: highlighted ? _dealOrange : _dealNavy),
    ));
  }
  return spans;
}

String _formatWholeCurrency(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '₹$buffer';
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.number, required this.isUnlocked});

  final PhoneNumber number;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: _dealOrange, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: _dealOrange.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DealCardHeader(number: number),
            _DealCardBody(number: number, isUnlocked: isUnlocked),
          ],
        ),
      ),
    );
  }
}

class _DealCardHeader extends StatelessWidget {
  const _DealCardHeader({required this.number});

  final PhoneNumber number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9A44), Color(0xFFF06A16)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(top: -30, right: -20, child: _GlowCircle(size: 110)),
          const Positioned(bottom: -50, left: -30, child: _GlowCircle(size: 130)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 98, child: _LogoPill()),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 44,
                    child: _VipBadge(
                      label: number.category.isNotEmpty
                          ? number.category.toUpperCase()
                          : 'VIP',
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 76,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'DEAL OF THE DAY',
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 6),
                        _LiveTag(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NumberPill(number: number.number),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.10),
      ),
    );
  }
}

class _LogoPill extends StatelessWidget {
  const _LogoPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Number',
                  style: TextStyle(
                    color: _dealNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'Wale',
                  style: TextStyle(
                    color: _dealOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Because Number Matters',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF9A9A9A),
              fontSize: 6.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VipBadge extends StatelessWidget {
  const _VipBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3A23C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 12),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTag extends StatelessWidget {
  const _LiveTag();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'LIVE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            children: _buildNumberSpans(number),
          ),
        ),
      ),
    );
  }
}

class _DealCardBody extends StatelessWidget {
  const _DealCardBody({required this.number, required this.isUnlocked});

  final PhoneNumber number;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = number.hasDiscount;
    final original = number.originalPrice ?? number.price;
    final finalPrice = number.discountedPrice;
    final savings = original - finalPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      color: Colors.white,
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FeatureBadge(
                icon: Icons.shield_outlined,
                bg: Color(0xFFDCF3FB),
                fg: Color(0xFF2AA9D8),
                label: 'RTP READY',
              ),
              _FeatureBadge(
                icon: Icons.location_on_outlined,
                bg: Color(0xFFEAE1FB),
                fg: Color(0xFF8A5CF6),
                label: 'PAN INDIA',
              ),
              _FeatureBadge(
                icon: Icons.bolt,
                bg: Color(0xFFFDF1CE),
                fg: Color(0xFFE0A62E),
                label: 'INSTANT PORT',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _DotIndicator(),
          const SizedBox(height: 18),
          SizedBox(
            height: 96,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: isUnlocked
                    ? _UnlockedPrice(
                        key: const ValueKey('unlocked'),
                        hasDiscount: hasDiscount,
                        original: original,
                        finalPrice: finalPrice,
                        savings: savings,
                        discount: number.discount,
                      )
                    : const _LockedPrice(key: ValueKey('locked')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.label,
  });

  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: fg, size: 19),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Color(0xFF8A8A8A),
          ),
        ),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator();

  Widget _dot(bool active) => Container(
        width: active ? 16 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: active ? _dealOrange : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(false),
        const SizedBox(width: 5),
        _dot(true),
        const SizedBox(width: 5),
        _dot(false),
      ],
    );
  }
}

class _LockedPrice extends StatelessWidget {
  const _LockedPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 30, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'PRICE LOCKED',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _UnlockedPrice extends StatelessWidget {
  const _UnlockedPrice({
    super.key,
    required this.hasDiscount,
    required this.original,
    required this.finalPrice,
    required this.savings,
    required this.discount,
  });

  final bool hasDiscount;
  final double original;
  final double finalPrice;
  final double savings;
  final int discount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatWholeCurrency(original),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              _PillBadge(
                text: '-$discount%',
                bg: const Color(0xFFDCF6E3),
                fg: const Color(0xFF1C9B4B),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: finalPrice),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Text(
                _formatWholeCurrency(value),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _dealOrange,
                ),
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 8),
              _PillBadge(
                text: 'SAVE ${_formatWholeCurrency(savings)}',
                bg: const Color(0xFFDCF6E3),
                fg: const Color(0xFF1C9B4B),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
        ),
      ),
    );
  }
}

class _DealActionButton extends StatelessWidget {
  const _DealActionButton({
    required this.isUnlocked,
    required this.onUnlock,
    required this.onClaim,
  });

  final bool isUnlocked;
  final VoidCallback onUnlock;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: isUnlocked
          ? _DepthButton(
              key: const ValueKey('claim'),
              label: 'CLAIM THIS NUMBER',
              bg: const Color(0xFFFF6A1F),
              shadowColor: const Color(0xFFB6410A),
              fg: Colors.white,
              icon: Icons.arrow_forward,
              onTap: onClaim,
            )
          : _DepthButton(
              key: const ValueKey('unlock'),
              label: 'UNLOCK TARGET DEAL',
              bg: const Color(0xFFFFD400),
              shadowColor: const Color(0xFF262626),
              fg: const Color(0xFF1A1A1A),
              onTap: onUnlock,
            ),
    );
  }
}

class _DepthButton extends StatelessWidget {
  const _DepthButton({
    super.key,
    required this.label,
    required this.bg,
    required this.shadowColor,
    required this.fg,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color bg;
  final Color shadowColor;
  final Color fg;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dash(),
        const SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 8,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Material(
              color: bg,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onTap,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        _Dash(),
      ],
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 3,
      decoration: BoxDecoration(
        color: _dealOrange,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
