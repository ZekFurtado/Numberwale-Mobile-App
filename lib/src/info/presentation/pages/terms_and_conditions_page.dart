import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _termsUrl = 'https://www.numberwale.com/terms-and-conditions';

/// The full Terms & Conditions are rendered behind a JS accordion on the
/// website with no server-rendered text, so this page links out to it
/// rather than reproducing (or worse, fabricating) legal copy natively.
class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  Future<void> _openTerms(BuildContext context) async {
    final uri = Uri.parse(_termsUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the Terms & Conditions page.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Terms & Conditions',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This is an electronic document under the Information '
                'Technology Act, 2000 and constitutes a binding agreement '
                'when you use Numberwale.com or this app. It covers '
                'membership eligibility, billing & payments, usage conduct, '
                'numerology services, refunds, and more, and is governed by '
                'the jurisdiction of the Thane/Mumbai courts.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Read the complete, up-to-date Terms & Conditions on our '
                'website.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => _openTerms(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Terms & Conditions'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
