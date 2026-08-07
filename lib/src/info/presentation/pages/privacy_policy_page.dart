import 'package:flutter/material.dart';

class _Highlight {
  const _Highlight(this.icon, this.title, this.description);

  final IconData icon;
  final String title;
  final String description;
}

const _highlights = <_Highlight>[
  _Highlight(
    Icons.lock_outline,
    'Data Security',
    'Advanced encryption protocols keep your name, contact, and business '
        'info secure.',
  ),
  _Highlight(
    Icons.block_outlined,
    'Zero Sharing',
    'We never sell, rent, or lease customer data. Your information is '
        'strictly private.',
  ),
  _Highlight(
    Icons.cookie_outlined,
    'Cookie Control',
    'Full transparency over cookie preferences. Choose what you share on '
        'your terms.',
  ),
  _Highlight(
    Icons.fact_check_outlined,
    'Your Rights',
    'Easily access, modify, or request deletion of your data from our '
        'database.',
  ),
];

class _Section {
  const _Section(this.title, this.body);

  final String title;
  final String body;
}

const _sections = <_Section>[
  _Section(
    'Numberwale.com Privacy Policy',
    'Numberwale.com is committed to protecting your privacy. This '
        'Statement of privacy applies to the Numberwale.com public website '
        'and governs data collection and usage. By using the Numberwale.com '
        'public website, you consent to the data practices described in '
        'this statement.',
  ),
  _Section(
    'Collection of your Personal Information',
    'Numberwale.com collects personally identifiable information, such as '
        'your Email Address, Name, Business Name, and State Location. We '
        'also collect anonymous demographic information like your postcode '
        'and product preferences.',
  ),
  _Section(
    'Use of your Personal Information',
    'Numberwale.com uses your personal information to operate its website '
        'and deliver requested services. Additionally, we may inform you '
        'about other products or services available and conduct surveys for '
        'research purposes. Numberwale.com does not sell, rent, or lease '
        'customer information to third parties. However, we track user '
        'activity within the website to improve our services.',
  ),
  _Section(
    'Use of Cookies',
    'The Numberwale.com website uses cookies to enhance your online '
        'experience. Cookies help personalize your visits and remember your '
        'preferences. You can accept or decline cookies in your browser '
        'settings.',
  ),
  _Section(
    'Security of your Personal Information',
    'We implement strong security measures to protect your personal data '
        'from unauthorized access, use, or disclosure. Our data is stored '
        'securely in controlled environments.',
  ),
  _Section(
    'Changes to this Statement',
    'Numberwale.com may update this Privacy Policy periodically. We '
        'encourage users to review this statement regularly to stay '
        'informed about how we protect your information.',
  ),
  _Section(
    'Coupon Codes and Promotions',
    'When you apply a coupon code or participate in a promotional offer, '
        'we collect data regarding the usage of these codes. This data is '
        'used to validate the discount, prevent fraudulent usage, enforce '
        'promotional terms, and analyze marketing effectiveness. We '
        'maintain the confidentiality of this data and do not share your '
        'promotional activity with unauthorized third-party advertisers.',
  ),
];

/// Mirrors the content at numberwale.com/privacy-policy.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Privacy Matters Us.',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your privacy is critically important to us. Learn how we '
              'collect, use, and protect your personal information.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                for (final h in _highlights)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(h.icon, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          h.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          h.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            for (var i = 0; i < _sections.length; i++) ...[
              Text(
                '${(i + 1).toString().padLeft(2, '0')}. ${_sections[i].title}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _sections[i].body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
