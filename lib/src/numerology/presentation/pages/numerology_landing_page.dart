import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_plan.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_score.dart';
import 'package:numberwale/src/numerology/domain/usecases/calculate_numerology_score.dart';

const _heroImages = [
  'https://www.numberwale.com/assets/numerology-1-iICcKd9T.jpeg',
  'https://www.numberwale.com/assets/numerology-2-DsHuhF8u.jpeg',
];

const _indigo = Color(0xFF6366F1);
const _rose = Color(0xFFF43F5E);
const _orange = Color(0xFFFF8401);

/// Mirrors the "Numerology" landing page at numberwale.com/numerology:
/// a hero image carousel, the three purchasable numerology report
/// packages, trust stats, and a live number calculator.
class NumerologyLandingPage extends StatelessWidget {
  const NumerologyLandingPage({super.key, this.showAppBar = true});

  /// False when the page is hosted as a bottom-navigation tab, where the
  /// app shell already supplies the title bar.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return _NumerologyLandingView(showAppBar: showAppBar);
  }
}

class _NumerologyLandingView extends StatefulWidget {
  const _NumerologyLandingView({required this.showAppBar});

  final bool showAppBar;

  @override
  State<_NumerologyLandingView> createState() =>
      _NumerologyLandingViewState();
}

class _NumerologyLandingViewState extends State<_NumerologyLandingView> {
  static const _calculator = CalculateNumerologyScore();

  final _numberController = TextEditingController();
  NumerologyScore? _score;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  int get _digitCount =>
      _numberController.text.replaceAll(RegExp(r'\D'), '').length;

  void _onNumberChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _score = digits.length == 10 ? _calculator(digits) : null;
    });
  }

  void _setExample(String formatted) {
    _numberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _onNumberChanged(formatted);
  }

  void _clear() {
    _numberController.clear();
    setState(() => _score = null);
  }

  void _goToConsultation(NumerologyPlan plan) {
    Navigator.pushNamed(
      context,
      Routes.numerologyConsultation,
      arguments: plan,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Numerology'),
              centerTitle: true,
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroImageCarousel(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _HeroText(theme: theme),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                children: [
                  _PricingCard(
                    badge: 'CURRENT NUMBER',
                    accent: _indigo,
                    icon: Icons.phone_iphone,
                    title: 'Existing Mobile Number Analyze',
                    subtitle: 'Numerology Analysis',
                    price: 299,
                    strikePrice: 500,
                    discountLabel: '40% OFF',
                    baseGstLabel: 'Base ₹254 + GST (18%) ₹45',
                    features: const [
                      'Numerology score of your current mobile number',
                      'Positive & negative number vibrations',
                      'Relationship & compatibility insights',
                      'Career & business influence analysis',
                      'Relationship impact report',
                      'Financial energy alignment',
                    ],
                    buttonText: 'Analyze My Current Number',
                    onPressed: () => _goToConsultation(NumerologyPlan.analyzeNumber),
                  ),
                  const SizedBox(height: 20),
                  _PricingCard(
                    badge: 'NEW NUMBER',
                    accent: _rose,
                    icon: Icons.auto_awesome,
                    title: 'New Number Guide Report',
                    subtitle: 'Mobile Number Suggestion',
                    price: 399,
                    strikePrice: 500,
                    discountLabel: '20% OFF',
                    baseGstLabel: 'Base ₹338 + GST (18%) ₹61',
                    features: const [
                      'Customized lucky number selection',
                      'Wealth & career alignment',
                      'Compatible digit combinations',
                      'Financial energy alignment',
                    ],
                    buttonText: 'Find My Lucky Number',
                    onPressed: () => _goToConsultation(NumerologyPlan.newNumberGuidance),
                  ),
                  const SizedBox(height: 20),
                  _PricingCard(
                    badge: 'BOTH REPORTS',
                    accent: _orange,
                    icon: Icons.workspace_premium,
                    title: 'Combo Mobile Number Report',
                    subtitle: 'New + Existing Mobile Number (Both Report)',
                    price: 499,
                    strikePrice: 999,
                    discountLabel: 'Best Value',
                    baseGstLabel: 'Base ₹423 + GST (18%) ₹76',
                    benefitsLabel: 'Combo Benefits',
                    features: const [
                      'Analyze existing mobile number',
                      'Receive personalized new number insights',
                      'Detailed numerology report explain',
                      'Lo Shu Grid Analysis',
                      'Compatibility Score',
                      'Remedial Suggestions',
                    ],
                    bestFor: const [
                      'Business owners',
                      'Professionals',
                      'Entrepreneurs',
                      'People planning number upgrade',
                    ],
                    buttonText: 'Get Combo Reports',
                    onPressed: () => _goToConsultation(NumerologyPlan.bothReports),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: _StatsRow(theme: theme),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
              child: _NumberCalculatorSection(
                theme: theme,
                controller: _numberController,
                digitCount: _digitCount,
                score: _score,
                onChanged: _onNumberChanged,
                onExampleTap: _setExample,
                onClear: _clear,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImageCarousel extends StatefulWidget {
  const _HeroImageCarousel();

  @override
  State<_HeroImageCarousel> createState() => _HeroImageCarouselState();
}

class _HeroImageCarouselState extends State<_HeroImageCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _page = index),
            itemCount: _heroImages.length,
            itemBuilder: (context, index) {
              return Image.network(
                _heroImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: Color(0xFFF3F4F6),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFF3F4F6),
                  child: Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 40),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          left: 8,
          child: _CarouselArrow(
            icon: Icons.chevron_left,
            onTap: () => _goTo((_page - 1 + _heroImages.length) % _heroImages.length),
          ),
        ),
        Positioned(
          right: 8,
          child: _CarouselArrow(
            icon: Icons.chevron_right,
            onTap: () => _goTo((_page + 1) % _heroImages.length),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _heroImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _page == index ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _page == index ? 1 : 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Over 10,000 Lives Transformed',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Is Your Mobile Number',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Lucky for You?',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _orange,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Discover your true potential through advanced numerology. '
          'Align your mobile number with success, wealth, and harmonious relationships.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.badge,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.strikePrice,
    required this.discountLabel,
    required this.baseGstLabel,
    required this.features,
    required this.buttonText,
    required this.onPressed,
    this.benefitsLabel,
    this.bestFor,
  });

  final String badge;
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final int price;
  final int strikePrice;
  final String discountLabel;
  final String baseGstLabel;
  final String? benefitsLabel;
  final List<String> features;
  final List<String>? bestFor;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$price',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹$strikePrice',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discountLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            baseGstLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          if (benefitsLabel != null) ...[
            Row(
              children: [
                Expanded(child: Divider(color: accent.withValues(alpha: 0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    benefitsLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: accent.withValues(alpha: 0.3))),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...features.map((f) => _FeatureRow(text: f, accent: accent)),
          if (bestFor != null) ...[
            const SizedBox(height: 16),
            Text(
              'BEST FOR',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bestFor!
                  .map((b) => Chip(
                        label: Text(b),
                        labelStyle: theme.textTheme.labelSmall,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(value: '10,000+', label: 'Happy Clients', theme: theme)),
          Expanded(child: _StatItem(value: '98%', label: 'Success Rate', theme: theme)),
          Expanded(child: _StatItem(value: '100%', label: 'Secure & Private', theme: theme)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.theme});

  final String value;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _NumberCalculatorSection extends StatelessWidget {
  const _NumberCalculatorSection({
    required this.theme,
    required this.controller,
    required this.digitCount,
    required this.score,
    required this.onChanged,
    required this.onExampleTap,
    required this.onClear,
  });

  final ThemeData theme;
  final TextEditingController controller;
  final int digitCount;
  final NumerologyScore? score;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onExampleTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_orange, Color(0xFFFFB74D)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calculate, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number Calculator',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Unlock the hidden numerology of any 10-digit mobile number',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'ENTER MOBILE NUMBER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _GroupedDigitsFormatter(),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 98765 43210',
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$digitCount/10 Digits',
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Examples:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _ExampleChip(label: '98765 43210', onTap: onExampleTap),
              _ExampleChip(label: '77777 77777', onTap: onExampleTap),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  label: 'Liter Sum',
                  caption: 'Sum of all digits',
                  value: score?.literSum,
                  accent: _indigo,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResultCard(
                  label: 'Mid Sum',
                  caption: 'Secondary Total',
                  value: score?.midSum,
                  accent: _rose,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResultCard(
                  label: 'Final Score',
                  caption: 'Numerological Root',
                  value: score?.finalScore,
                  accent: _orange,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: _orange),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                          text: 'How it works: ',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                        TextSpan(
                          text: 'Enter a complete 10-digit mobile number to unveil its '
                              'numerical significance. The calculations will appear '
                              'automatically once all 10 digits are filled.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  const _ExampleChip({required this.label, required this.onTap});

  final String label;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onTap(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: _orange.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: _orange,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.label,
    required this.caption,
    required this.value,
    required this.accent,
    required this.theme,
  });

  final String label;
  final String caption;
  final int? value;
  final Color accent;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${value ?? 0}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats raw digits as "XXXXX XXXXX" (max 10 digits).
class _GroupedDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 10 ? digits.substring(0, 10) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i == 5) buffer.write(' ');
      buffer.write(trimmed[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
