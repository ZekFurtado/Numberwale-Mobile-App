import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberwale/src/info/presentation/widgets/legal_page_ui.dart';

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
  const _Section(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}

const _sections = <_Section>[
  _Section(
    'Numberwale.com Privacy Policy',
    [
      'Numberwale.com is committed to protecting your privacy. This '
          'Statement of privacy applies to the Numberwale.com public website '
          'and governs data collection and usage. By using the Numberwale.com '
          'public website, you consent to the data practices described in '
          'this statement.',
    ],
  ),
  _Section(
    'Collection of your Personal Information',
    [
      'Numberwale.com collects personally identifiable information, such as '
          'your Email Address, Name, Business Name, and State Location. We '
          'also collect anonymous demographic information like your postcode '
          'and product preferences.',
    ],
  ),
  _Section(
    'Use of your Personal Information',
    [
      'Numberwale.com uses your personal information to operate its website '
          'and deliver requested services. Additionally, we may inform you '
          'about other products or services available and conduct surveys for '
          'research purposes.',
      'Numberwale.com does not sell, rent, or lease customer information to '
          'third parties. However, we track user activity within the website '
          'to improve our services.',
    ],
  ),
  _Section(
    'Use of Cookies',
    [
      'The Numberwale.com website uses cookies to enhance your online '
          'experience. Cookies help personalize your visits and remember your '
          'preferences. You can accept or decline cookies in your browser '
          'settings.',
    ],
  ),
  _Section(
    'Security of your Personal Information',
    [
      'We implement strong security measures to protect your personal data '
          'from unauthorized access, use, or disclosure. Our data is stored '
          'securely in controlled environments.',
    ],
  ),
  _Section(
    'Changes to this Statement',
    [
      'Numberwale.com may update this Privacy Policy periodically. We '
          'encourage users to review this statement regularly to stay '
          'informed about how we protect your information.',
    ],
  ),
  _Section(
    'Coupon Codes and Promotions',
    [
      'When you apply a coupon code or participate in a promotional offer, '
          'we collect data regarding the usage of these codes. This data is '
          'used to validate the discount, prevent fraudulent usage, enforce '
          'promotional terms, and analyze marketing effectiveness. We '
          'maintain the confidentiality of this data and do not share your '
          'promotional activity with unauthorized third-party advertisers.',
    ],
  ),
];

/// Mirrors the mobile layout of numberwale.com/privacy-policy: gradient
/// hero, highlight cards, a sticky section-jump pill bar with scroll-spy,
/// and numbered section cards.
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final _scrollController = ScrollController();
  final _sectionKeys = List.generate(_sections.length, (_) => GlobalKey());
  int _activeIndex = 0;
  DateTime? _suppressScrollSpyUntil;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final suppressUntil = _suppressScrollSpyUntil;
    if (suppressUntil != null && DateTime.now().isBefore(suppressUntil)) {
      return;
    }
    const threshold = 200.0;
    var active = 0;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final box =
          _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      if (box.localToGlobal(Offset.zero).dy <= threshold) {
        active = i;
      } else {
        break;
      }
    }
    if (active != _activeIndex) setState(() => _activeIndex = active);
  }

  void _scrollToSection(int index) {
    _suppressScrollSpyUntil = DateTime.now().add(
      const Duration(milliseconds: 500),
    );
    setState(() => _activeIndex = index);
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LegalColors.gray50, Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    const LegalHero(
                      icon: Icons.privacy_tip_outlined,
                      badgeLabel: 'YOUR PRIVACY MATTERS US.',
                      title: 'Privacy Policy',
                      subtitle:
                          'Your privacy is critically important to us. Learn '
                          'how we collect, use, and protect your personal '
                          'information.',
                    ),
                    const SizedBox(height: 24),
                    for (final h in _highlights) ...[
                      LegalHighlightCard(
                        icon: h.icon,
                        title: h.title,
                        description: h.description,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: LegalTocBarDelegate(
                titles: [for (final s in _sections) s.title],
                activeIndex: _activeIndex,
                onTap: _scrollToSection,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    key: _sectionKeys[i],
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SectionCard(
                      index: i,
                      section: _sections[i],
                      active: i == _activeIndex,
                    ),
                  ),
                  childCount: _sections.length,
                ),
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
    required this.index,
    required this.section,
    required this.active,
  });

  final int index;
  final _Section section;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active ? LegalColors.orange200 : LegalColors.gray100,
        ),
        boxShadow: [
          BoxShadow(
            color: active
                ? LegalColors.primary.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.015),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LegalSectionNumber(index),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: LegalColors.gray900,
                  ),
                ),
                const SizedBox(height: 16),
                for (final p in section.paragraphs) ...[
                  Text(
                    p,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      height: 1.6,
                      color: LegalColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
