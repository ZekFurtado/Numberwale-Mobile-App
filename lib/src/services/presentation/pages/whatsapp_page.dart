import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numberwale/src/services/presentation/widgets/step_walkthrough.dart';
import 'package:video_player/video_player.dart';

const _orange = kServiceOrange;
const _bodyGray = kServiceBodyGray;

const _mainDemoVideo =
    'https://www.numberwale.com/assets/Whatsapp-API-Providers-DdsQmXP2.mp4';

const _introText =
    'Our WhatsApp Solution platform provides businesses with powerful tools '
    'to engage customers effectively through WhatsApp messaging. With our '
    'intuitive dashboard, chatbot functionality, and collaborative tools, '
    'you can create seamless customer experiences that drive engagement and '
    'results.';

final _steps = [
  const StepItem(
    number: 1,
    title: 'Chatbot',
    media: _StepVideo(url: _mainDemoVideo),
    text:
        "Within minutes, install the no-code WhatsApp Chatbot - and say hi "
        "to your company's Digital Assistant. Build better customer "
        'engagement. Capture more leads. Offer better Support. Automate '
        'your mundane replies to customer queries where predefined options '
        'and answers guide your customers in their service journey.',
  ),
  const StepItem(
    number: 2,
    title: 'Multiple Agents',
    media: _StepVideo(url: _mainDemoVideo),
    text:
        'In order to manage customer service or sales operations, one of '
        'the problems that companies encounter using WhatsApp is not being '
        'able to allow their agents to access the same company account '
        'from multiple devices at the same time. This problem is solved by '
        'our Numberwale Whatsapp Business API that allows sales or support '
        'teams to work collaboratively from a single platform.',
  ),
  const StepItem(
    number: 3,
    title: 'Private Notes',
    media: _StepVideo(
        url: 'https://www.numberwale.com/assets/privatenotes-30WRe7Lv.mp4'),
    text:
        'Add private notes against contacts. Add private notes in a '
        'conversation. Restrict or open information to users within the '
        'organization. Make customer interactions more personal and track '
        'important information across your team.',
  ),
  const StepItem(
    number: 4,
    title: 'Collaboration',
    media: _StepVideo(url: _mainDemoVideo),
    text:
        'The great feature by WhatsApp API offers world-class collaboration '
        'for your team-members so they are never stuck when they need '
        'help. Leave no customer behind. Empower your teams so they can '
        'provide on-the-go resolution to customers and deliver exceptional '
        'service every time.',
  ),
  const StepItem(
    number: 5,
    title: 'Quick Replies',
    media: _StepVideo(url: _mainDemoVideo),
    text:
        'The Numberwale WhatsApp API provides you a quick respond feature '
        'to your customers with a single click. Pre-defined rich text '
        'snippets for better customer experience. Create call-to-actions '
        'and quick reply buttons within WhatsApp to get immediate '
        'responses from your audience.',
  ),
  const StepItem(
    number: 6,
    title: 'Actionable Dashboards',
    media: _StepVideo(url: _mainDemoVideo),
    text:
        'The Numberwale WhatsApp API provides you the 360 degree view of '
        'digital conversations. Monitor and take action based on '
        'insightful reports & dashboard. That helps you to keep an eye on '
        'every process that is executing and optimize your customer '
        'communication strategies.',
  ),
  const StepItem(
    number: 7,
    title: 'Customer Profiling',
    media: _StepVideo(url: _mainDemoVideo),
    text:
        'Customer profiling is one of the best features to locate your '
        'customer. This feature is provided by Numberwale WhatsAPI. '
        'Intelligent labels help you to profile your customers for future '
        'actions and re-targeting, allowing for personalized '
        'communications and better conversion rates.',
  ),
  const StepItem(
    number: 8,
    title: 'Rich Text',
    media: _StepVideo(url: _mainDemoVideo),
    text:
        'Get interact with your customer easily by sharing images, '
        'electronic tickets, video tutorials, audio files, QR codes, the '
        'position of the closest store, and any sort of documents through '
        'Numberwale WhatsApp API. Enhance your customer engagement with '
        'rich media capabilities.',
  ),
];

class _Benefit {
  const _Benefit({
    required this.title,
    required this.descriptions,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final List<String> descriptions;
  final IconData icon;
  final Color iconColor;
}

const _benefits = [
  _Benefit(
    title: 'INCREASE CUSTOMER RESPONSE RATE',
    descriptions: [
      'Get notified of any customer conversation in real-time.',
      'Reply swiftly through pre-defined messaging templates.',
    ],
    icon: Icons.forum,
    iconColor: Color(0xFF67E8F9),
  ),
  _Benefit(
    title: 'GROW YOUR BRAND SALIENCE',
    descriptions: [
      'Build and enhance your brand image on a foundation of customer trust.',
      'By providing instant and relevant support to your customers.',
    ],
    icon: Icons.campaign,
    iconColor: Color(0xFFD8B4FE),
  ),
  _Benefit(
    title: 'EARN CUSTOMER DELIGHT',
    descriptions: [
      'Customers demand one-to-one service and be the one, offering it so '
          'you earn scores of delighted customers.',
    ],
    icon: Icons.sentiment_satisfied_alt,
    iconColor: Color(0xFFF9A8D4),
  ),
  _Benefit(
    title: 'IMPROVE IN-BOUND CONVERSIONS',
    descriptions: [
      'When customers discover you, convert these prospects faster with '
          'better tools at your disposal.',
    ],
    icon: Icons.trending_up,
    iconColor: Color(0xFF86EFAC),
  ),
  _Benefit(
    title: 'GROW CUSTOMER LOYALTY',
    descriptions: [
      "Customers love you when you do not take them away from their "
          "'home' - their messaging platform. They find it easy to come "
          'back to you.',
    ],
    icon: Icons.favorite,
    iconColor: Color(0xFFFDBA74),
  ),
  _Benefit(
    title: 'MAINTAIN COMMUNICATION STANDARDS',
    descriptions: [
      'WhatsApp Business Templates and canned response help your sales and '
          'support team to communicate in a specific standards',
    ],
    icon: Icons.verified,
    iconColor: Color(0xFFFACC15),
  ),
];

/// Mirrors the "WhatsApp Solution" product page at
/// numberwale.com/products/whatsapp: the orange hero banner, the featured
/// demo video, the numbered "how it works" walkthrough (with per-step demo
/// videos), the "Power your Business WhatsApp channel" chain graphic, and
/// the business-benefits grid — laid out for a single mobile column.
class WhatsappPage extends StatelessWidget {
  const WhatsappPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp API'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF9FAFB)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _HeroCard(),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: _StepVideo(url: 'https://www.numberwale.com/assets/wha-CXayNC7b.mp4'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'HOW OUR WHATSAPP SOLUTION WORKS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _orange,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      _introText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _bodyGray, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    StepWalkthrough(steps: _steps),
                    const SizedBox(height: 32),
                    const _PowerCta(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const _BenefitsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Text(
        'WhatsApp Solution',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Autoplaying, looping, muted video used both for the featured promo clip
/// and for each walkthrough step's demo recording.
class _StepVideo extends StatefulWidget {
  const _StepVideo({required this.url});

  final String url;

  @override
  State<_StepVideo> createState() => _StepVideoState();
}

class _StepVideoState extends State<_StepVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      }).catchError((Object _) {
        if (!mounted) return;
        setState(() => _failed = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Color(0xFFF3F4F6),
          child: Center(
            child: Icon(Icons.videocam_off_outlined, size: 40),
          ),
        ),
      );
    }
    if (!_ready) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Color(0xFFF3F4F6),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}

class _PowerCta extends StatelessWidget {
  const _PowerCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Power your Business WhatsApp\nchannel with Numberwale',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ChainIcon(
                bg: const Color(0xFF22C55E),
                icon: FontAwesomeIcons.whatsapp,
                iconColor: Colors.white,
                label: 'WhatsApp',
              ),
              const _ChainConnector(),
              const _NumberwaleBadge(),
              const _ChainConnector(),
              _ChainIcon(
                bg: const Color(0xFFF3F4F6),
                icon: Icons.trending_up,
                iconColor: const Color(0xFF22C55E),
                label: 'Sales',
              ),
              const _ChainConnector(),
              _ChainIcon(
                bg: const Color(0xFFFEF3C7),
                icon: Icons.groups,
                iconColor: const Color(0xFFFACC15),
                label: 'Customers',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChainIcon extends StatelessWidget {
  const _ChainIcon({
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final Color bg;
  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

class _NumberwaleBadge extends StatelessWidget {
  const _NumberwaleBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              color: const Color(0xFFFFEDD5),
              child: Transform.rotate(
                angle: 12 * 3.14159265 / 180,
                child: Container(
                  color: _orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                  child: const Text(
                    'NUMBERWALE.COM',
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 5,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Numberwale',
              style: TextStyle(fontSize: 11, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

class _ChainConnector extends StatelessWidget {
  const _ChainConnector();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Icon(Icons.add, color: Color(0xFF3B82F6), size: 18),
      );
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'BENEFITS',
            style: TextStyle(color: Color(0xFF374151), fontSize: 18),
          ),
          const SizedBox(height: 2),
          const Text(
            'TO YOUR BUSINESS',
            style: TextStyle(
              color: _orange,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          for (final benefit in _benefits) ...[
            _BenefitCard(benefit: benefit),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefit});

  final _Benefit benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 56, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                benefit.title,
                style: const TextStyle(
                  color: _orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (final d in benefit.descriptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    d,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(benefit.icon, color: benefit.iconColor, size: 32),
          ),
        ],
      ),
    );
  }
}
