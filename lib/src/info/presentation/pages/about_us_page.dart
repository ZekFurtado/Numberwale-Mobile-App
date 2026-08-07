import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/info/presentation/widgets/marketing_widgets.dart';

class _Benefit {
  const _Benefit(this.icon, this.title, this.description, this.bg, this.fg);

  final IconData icon;
  final String title;
  final String description;
  final Color bg;
  final Color fg;
}

const _benefits = <_Benefit>[
  _Benefit(
    Icons.workspace_premium_outlined,
    '10+ Years Legacy',
    'Come be a part of the Numberwale family. Over a decade of delivering '
        'special communication experiences and trust across India.',
    Color(0xFFFFE8D6),
    Color(0xFFEA7A1A),
  ),
  _Benefit(
    Icons.shield_outlined,
    'Trusted Partners',
    'Full GST compliance and official invoice provisions. We are legal, '
        'secure, and professional communication partners.',
    Color(0xFFE3EEFF),
    Color(0xFF4C7EFF),
  ),
  _Benefit(
    Icons.bolt_outlined,
    'Hassle-Free Delivery',
    'Super fast activation, easy access, and quick porting process. Stay '
        'connected with zero processing delays.',
    Color(0xFFFFF3D6),
    Color(0xFFE0A100),
  ),
  _Benefit(
    Icons.favorite_border,
    'Desired Selections',
    'Find the exact digit patterns you want. Choose from lakhs of premium '
        'numbers tailored to your brand or personal style.',
    Color(0xFFFFE3E8),
    Color(0xFFFF4D6D),
  ),
];

/// Mirrors the "Why Us" page at numberwale.com/why-us.
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  void _browseNumbers(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.appShell,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
      ),
      body: MarketingBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      const Color(0xFFFF6B35),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const PillBadge(
                      label: '10+ YEARS OF TRUST & EXCELLENCE',
                      background: Colors.white24,
                      foreground: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'WHY CHOOSE US?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Numberwale.com is India's leading telecom VIP number "
                      'provider. We make your communication special, '
                      'memorable, and unique.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quote card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '"Have your desired phone model? Also, own your '
                      'desired service provider? Then why not your desired '
                      'number!"',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '•  YOUR NUMBER, YOUR IDENTITY  •',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Benefit cards
              for (final benefit in _benefits) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(
                        icon: benefit.icon,
                        background: benefit.bg,
                        foreground: benefit.fg,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        benefit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        benefit.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 6),

              // Dark CTA card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF14171F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to Find Your Desired Number?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join lakhs of happy clients who upgraded their '
                      'personal and business presence. Stay connected, '
                      'always.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _browseNumbers(context),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Browse VIP Numbers'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
