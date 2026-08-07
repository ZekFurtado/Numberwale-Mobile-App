import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/contact/presentation/bloc/contact_bloc.dart';
import 'package:numberwale/src/info/presentation/widgets/marketing_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class _Stat {
  const _Stat(this.value, this.suffix, this.label);

  final String value;
  final String suffix;
  final String label;
}

const _stats = <_Stat>[
  _Stat('2', 'Hrs', 'AVERAGE RESPONSE'),
  _Stat('100', '%', 'SATISFACTION RATE'),
  _Stat('24', '/7', 'VIP ASSISTANCE'),
  _Stat('1', 'Lakh+', 'HAPPY CLIENTS'),
];

class _Social {
  const _Social(this.icon, this.background, this.onTap);

  final IconData icon;
  final Color background;
  final Future<void> Function()? onTap;
}

/// Mirrors the content and visual design of numberwale.com/contact-us.
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ContactUsView();
  }
}

class _ContactUsView extends StatefulWidget {
  const _ContactUsView();

  @override
  State<_ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<_ContactUsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _messageController = TextEditingController();
  final _companyNameController = TextEditingController();

  String? _selectedEnquiryType = 'General Enquiry';
  bool _agreed = false;

  late final _termsTap = TapGestureRecognizer()
    ..onTap = () => Navigator.pushNamed(context, Routes.termsAndConditions);
  late final _privacyTap = TapGestureRecognizer()
    ..onTap = () => Navigator.pushNamed(context, Routes.privacyPolicy);

  static const List<String> _enquiryTypes = [
    'General Enquiry',
    'Order Support',
    'Payment Issue',
    'Number Availability',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    _companyNameController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please agree to the Terms & Conditions and Privacy Policy.',
          ),
        ),
      );
      return;
    }
    context.read<ContactBloc>().add(SubmitContactFormEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobileNo: _mobileController.text.trim(),
          message: _messageController.text.trim(),
          companyName: _companyNameController.text.trim().isEmpty
              ? null
              : _companyNameController.text.trim(),
          type: _selectedEnquiryType,
        ));
  }

  Future<void> _call(String phone) =>
      launchUrl(Uri(scheme: 'tel', path: phone));

  Future<void> _email(String email) =>
      launchUrl(Uri(scheme: 'mailto', path: email));

  Future<void> _openMaps(String address) => launchUrl(
        Uri.parse(
          'https://www.google.com/maps/search/?api=1&query='
          '${Uri.encodeComponent(address)}',
        ),
        mode: LaunchMode.externalApplication,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const address =
        '005, Building no.12-B, Sangeet complex, Jesal Park, Bhayandar '
        'East, Thane, Maharashtra - 401105';

    final socials = <_Social>[
      _Social(
        FontAwesomeIcons.whatsapp,
        const Color(0xFF25D366),
        () => launchUrl(Uri.parse('https://wa.me/919222222007')),
      ),
      _Social(
        FontAwesomeIcons.instagram,
        const Color(0xFFE1306C),
        () => launchUrl(Uri.parse('https://www.instagram.com/numberwale/')),
      ),
      _Social(
        FontAwesomeIcons.facebookF,
        const Color(0xFF1877F2),
        () => launchUrl(Uri.parse('https://www.facebook.com/NumberWale/')),
      ),
      const _Social(FontAwesomeIcons.xTwitter, Colors.black, null),
      const _Social(FontAwesomeIcons.linkedinIn, Color(0xFF0A66C2), null),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: BlocConsumer<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Your message has been submitted. We will get back to you shortly.'),
              ),
            );
            Navigator.pop(context);
          } else if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ContactLoading;

          return MarketingBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero
                  const Center(child: PillBadge(label: 'CONNECT INSTANTLY')),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        TextSpan(
                          text: "Let's Start a ",
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        TextSpan(
                          text: 'Conversation',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We'd love to hear from you. Get in touch with our team "
                    'for VIP mobile numbers, custom telecom setups, and '
                    'premium digital solutions.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      for (final stat in _stats) _StatCard(stat: stat),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Corporate & Support
                  const DotSectionLabel('Corporate & Support'),
                  const SizedBox(height: 12),
                  _InfoCard(
                    children: [
                      _ContactRow(
                        icon: Icons.business_outlined,
                        label: 'Numberwale HQ',
                        value: address,
                        onTap: () => _openMaps(address),
                      ),
                      const Divider(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GST Registration',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const PillBadge(label: '27BQXPS4248A1ZE'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      _ContactRow(
                        icon: Icons.phone_outlined,
                        label: 'Direct Phone',
                        value: '+91 9222 222 007',
                        onTap: () => _call('+919222222007'),
                      ),
                      const SizedBox(height: 16),
                      _ContactRow(
                        icon: Icons.email_outlined,
                        label: 'Email Support',
                        value: 'support@numberwale.com',
                        onTap: () => _email('support@numberwale.com'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sales Department
                  Row(
                    children: [
                      const DotSectionLabel('Sales Department'),
                      const SizedBox(width: 10),
                      const PillBadge(
                        label: 'ACTIVE',
                        background: Color(0xFFE3F8EA),
                        foreground: Color(0xFF1CA652),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    children: [
                      _ContactRow(
                        icon: Icons.schedule_outlined,
                        label: 'Timings',
                        value: 'Monday to Saturday, 10:00 AM to 07:00 PM',
                      ),
                      const SizedBox(height: 16),
                      _ContactRow(
                        icon: Icons.support_agent_outlined,
                        label: 'Sales Helpline',
                        value: '+91 9222 222 007',
                        onTap: () => _call('+919222222007'),
                      ),
                      const SizedBox(height: 16),
                      _ContactRow(
                        icon: Icons.email_outlined,
                        label: 'Sales Email',
                        value: 'sales@numberwale.com',
                        onTap: () => _email('sales@numberwale.com'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social
                  Center(
                    child: Text(
                      'CONNECT ON SOCIAL MEDIA',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final social in socials) ...[
                        _SocialButton(social: social),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Send a Message
                  _InfoCard(
                    children: [
                      Text(
                        'Send a Message',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Have inquiries? Write to us, and our representative '
                        'will call you back shortly.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _selectedEnquiryType,
                              decoration: const InputDecoration(
                                labelText: 'Enquiry Type',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: _enquiryTypes
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEnquiryType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Your Name *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-mail Address *',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(v.trim())) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number *',
                                prefixIcon: Icon(Icons.phone_outlined),
                                counterText: '',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Mobile number is required';
                                }
                                if (v.trim().length != 10) {
                                  return 'Please enter a valid 10-digit '
                                      'mobile number';
                                }
                                if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                                  return 'Mobile number must contain only '
                                      'digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _companyNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Company Name (Optional)',
                                prefixIcon: Icon(Icons.business_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Message *',
                                hintText: 'Tell us about the VIP Number or '
                                    'service you are interested in...',
                                alignLabelWithHint: true,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Message is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () =>
                                  setState(() => _agreed = !_agreed),
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _agreed,
                                    onChanged: (v) =>
                                        setState(() => _agreed = v ?? false),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: RichText(
                                        text: TextSpan(
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: '* By submitting, I '
                                                  'agree to the ',
                                            ),
                                            TextSpan(
                                              text: 'Terms & Conditions',
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              recognizer: _termsTap,
                                            ),
                                            const TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              recognizer: _privacyTap,
                                            ),
                                            const TextSpan(
                                              text: ' and consent to receive '
                                                  'updates through '
                                                  'SMS/Email/WhatsApp.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Send Message'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location
                  _InfoCard(
                    children: [
                      Text(
                        'Our Location',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              address,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _openMaps(address),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Open in Maps'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Visit us at Numberwale, located in the heart of '
                        'the city!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(text: stat.value),
                TextSpan(
                  text: stat.suffix,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.social});

  final _Social social;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: social.onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: social.background,
          shape: BoxShape.circle,
        ),
        child: Icon(social.icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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
