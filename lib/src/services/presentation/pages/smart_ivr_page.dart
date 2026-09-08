import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

const _orange = Color(0xFFFF8400);
const _titleGray = Color(0xFF474B67);
const _bodyGray = Color(0xFF8A8A8A);

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.vipmobilenumbers.numberwale';

class _Feature {
  const _Feature({required this.icon, required this.title, required this.text});
  final String icon;
  final String title;
  final String text;
}

class _Step {
  const _Step({
    required this.number,
    required this.title,
    required this.text,
    required this.image,
    this.isSvg = false,
    this.svgData,
    this.leadingIcon,
  });

  final int number;
  final String title;
  final String text;
  final String image;
  final bool isSvg;

  /// Raw (percent-encoded) inline SVG markup, used instead of [image] when set.
  final String? svgData;
  final Widget? leadingIcon;
}

const _features = [
  _Feature(
    icon: 'https://www.numberwale.com/assets/icon01-FeX8RIGb.png',
    title: 'Cloud EPABX',
    text:
        'Distribute calls among your team members with Automatic Call Distribution ensuring business scalability involving no set-up or hardware cost.',
  ),
  _Feature(
    icon: 'https://www.numberwale.com/assets/icon02-B74v2HNy.png',
    title: 'Virtual numbers',
    text:
        "Get the forwarding number's advantage for all your marketing channels. Track the performance and RoI.",
  ),
  _Feature(
    icon: 'https://www.numberwale.com/assets/icon03-CCfGu5D-.png',
    title: 'Custom IVR',
    text:
        'Get an IVR for your business that addresses your callers with a personalized voice. Greet your callers with a professional voice, every time they make a call.',
  ),
  _Feature(
    icon: 'https://www.numberwale.com/assets/icon04-Cem-5SL4.png',
    title: 'Analytical reports',
    text:
        'Analyse the reports to check how effective is your communication. Subscribe for email and SMS reports of your business calls.',
  ),
  _Feature(
    icon: 'https://www.numberwale.com/assets/icon05-DQ8w0Zum.png',
    title: 'Call recording',
    text:
        'Record all the business calls received or answered. Use the recordings to improve the quality of your service.',
  ),
];

const _introText =
    'IVR stands for Interactive Voice Response. This is basically a technology '
    'that enables a conversation or interaction between a computer and a human. '
    'For example, when a person calls, the IVR (pre-recorded) greets the caller '
    'with a welcome message. The caller is then required to choose from a '
    'predefined set of options such as press 1 for business, press 2 for sales, '
    'press 3 for support and so on. After the choice is made by the caller, the '
    'call is routed to the chosen department/agent. If none of your agents '
    'answers the call, it automatically gets sent to a voice mail and can be '
    'then reviewed upon for action.';

final _steps = [
  const _Step(
    number: 1,
    title: 'Pick a number',
    image: 'https://www.numberwale.com/assets/PICK-A-NUMBERV2-Hd49sha-.png',
    text:
        'Having your own number is one of the benefits of getting your Number '
        'Wale business phone number which could either be a toll-free or '
        'virtual number. You also get access to a web account that makes it '
        'easy for you to monitor your business calls, get user and department '
        'wise details, analyse call data and reports. You can also add '
        'contacts and users and define a role for each user, making it a '
        'seamless process to begin with.',
  ),
  const _Step(
    number: 2,
    title: 'Design your custom IVR',
    image:
        'https://www.numberwale.com/assets/DESIGN-YOUR-CUSTOM-IVR-DPdiX6Lr.png',
    text:
        'Like customization or have a likeness towards a favourite digit? Get '
        'it customized through professional IVR for your Number Wale business '
        'phone number. The IVR routes all the calls to their respective '
        'department/agent. If no user answers the call, the call gets '
        'transferred to a voicemail for further review. Map all your '
        'departments and users. You can also create and design a '
        'location-based, contact-based or time-based IVR for your business, '
        'depending on your requirement and business.',
  ),
  const _Step(
    number: 3,
    title: 'Add departments and agents',
    image:
        'https://www.numberwale.com/assets/ADD-DEPARTMENTS-AND-AGENTS-C4YegFSB.png',
    text:
        'To make the entire telecommunication process efficient, every '
        'different department can be categorized in your professional IVR '
        'such as business, sales, support to name a few. It is easier to '
        'assign users to each department and define a role for each such as '
        'super admin, the moderator or basic. Also, create extension numbers '
        'for each user for direct contact.',
  ),
  _Step(
    number: 4,
    title: 'Publish the number',
    image: 'https://www.numberwale.com/assets/PUBLISH-THE-NUMBER-B9IOH8gx.png',
    text:
        'Get your Number Wale phone number published on online and offline '
        'forums to popularise it. Such forums include your website, '
        'advertisements, business cards and social media. Increase brand '
        'recognition through your centralised phone number.',
    leadingIcon: const Icon(Icons.campaign, color: _orange, size: 22),
  ),
  _Step(
    number: 5,
    title: 'View and subscribe for call reports',
    image: 'https://www.numberwale.com/assets/05-Ckf8-4m-.svg',
    isSvg: true,
    text:
        'Subscribe to your Number Wale for call reports. These reports help '
        'you understand the interaction journey better and make amends '
        'wherever required. This helps to set up an organized way of '
        'telecommunication within your organization.',
    leadingIcon: Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle),
      child: const Icon(Icons.check, color: Colors.white, size: 16),
    ),
  ),
  const _Step(
    number: 6,
    title: 'Remarket the callers',
    image: '',
    isSvg: true,
    svgData: _remarketSvg,
    text:
        'Looking for a way to reconnect with your callers? It is easier to '
        'reach back to your callers through SMS and Facebook Remarketing. '
        'Select subscription lists to reconnect with your callers via '
        'customized campaigns based on their call attributes and affinities. '
        'Also, subscribe for call reports to analyse the RoI of your '
        'marketing campaigns.',
  ),
];

/// Mirrors the "Smart IVR" product page at numberwale.com/products/smart-ivr:
/// the orange hero banner, key-feature cards, and the numbered "how an IVR
/// works" walkthrough, laid out for a single mobile column.
class SmartIvrPage extends StatelessWidget {
  const SmartIvrPage({super.key});

  Future<void> _openPlayStore() =>
      launchUrl(Uri.parse(_playStoreUrl), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart IVR'),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HeroCard(),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _openPlayStore,
                  child: Image.network(
                    'https://www.numberwale.com/assets/android-DE0WBqEZ.png',
                    width: 96,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 32),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Key Features',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _orange,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              for (final feature in _features) ...[
                _FeatureCard(feature: feature),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 20),
              const Text(
                'WHAT IS AN IVR? HOW DOES IT WORK?',
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
                style: TextStyle(color: _bodyGray, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              for (var i = 0; i < _steps.length; i++) ...[
                _StepBlock(step: _steps[i]),
                if (i < _steps.length - 1) const _StepConnector(),
              ],
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
      child: Column(
        children: [
          const Text(
            'Smart IVR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://www.numberwale.com/assets/howitwork-Cd4BAuB8.png',
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 160,
                child: Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Image.network(
            feature.icon,
            width: 56,
            height: 56,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.settings_phone, color: _orange, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _titleGray,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _bodyGray, fontSize: 13.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _StepBlock extends StatelessWidget {
  const _StepBlock({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _StepImage(step: step),
            ),
            Positioned(
              top: -12,
              left: -12,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${step.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (step.leadingIcon != null) ...[
              step.leadingIcon!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                step.title.toUpperCase(),
                style: const TextStyle(
                  color: _titleGray,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          step.text,
          textAlign: TextAlign.justify,
          style: const TextStyle(color: _bodyGray, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class _StepImage extends StatelessWidget {
  const _StepImage({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    const height = 200.0;

    if (step.svgData != null) {
      return SvgPicture.string(
        Uri.decodeComponent(step.svgData!),
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
      );
    }

    if (step.isSvg) {
      return SvgPicture.network(
        step.image,
        width: double.infinity,
        height: height,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const SizedBox(
          height: height,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Image.network(
      step.image,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          height: height,
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 40),
        ),
      ),
    );
  }
}

/// Vertical stand-in for the wavy dashed connector drawn between steps on
/// the (horizontally laid out) desktop site.
class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 2, height: 16, color: _orange.withValues(alpha: 0.4)),
            const Icon(Icons.keyboard_arrow_down, color: _orange, size: 20),
          ],
        ),
      ),
    );
  }
}

// Percent-encoded inline SVG used for step 6 on the source page (an
// illustration accompanying "Remarket the callers"), decoded at render time.
const _remarketSvg =
    "%3c?xml%20version='1.0'%20encoding='utf-8'?%3e%3c!--%20Generator:%20Adobe%20Illustrator%2016.0.0,%20SVG%20Export%20Plug-In%20.%20SVG%20Version:%206.00%20Build%200)%20--%3e%3c!DOCTYPE%20svg%20PUBLIC%20'-//W3C//DTD%20SVG%201.1//EN'%20'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'%3e%3csvg%20version='1.1'%20id='Layer_1'%20xmlns='http://www.w3.org/2000/svg'%20xmlns:xlink='http://www.w3.org/1999/xlink'%20x='0px'%20y='0px'%20width='3456px'%20height='2592px'%20viewBox='0%200%203456%202592'%20enable-background='new%200%200%203456%202592'%20xml:space='preserve'%3e%3ctitle%3eGet%20Exophone%3c/title%3e%3cg%20id='Layer_2'%3e%3cg%20id='Layer_1-2'%3e%3crect%20x='-113.663'%20y='324.704'%20transform='matrix(-0.7674%20-0.6412%200.6412%20-0.7674%201797.2002%203570.5945)'%20fill='none'%20width='3319.897'%20height='2269.183'/%3e%3cpolygon%20fill='%23F89303'%20points='2189.152,1165.304%202421.591,1359.508%201836.977,2127.137%201674.211,1991.754%20'/%3e%3cpath%20fill='%23FD8E87'%20d='M2650.541,1185.761c16.689,70.455-6.324,162.093-51.403,204.681%20c-45.077,42.586-95.149,19.993-111.84-50.461c-16.688-70.457,6.327-162.094,51.405-204.681%20C2583.78,1092.715,2633.854,1115.307,2650.541,1185.761z'/%3e%3cpath%20fill='%23AD6415'%20d='M2281.347,1543.658l-1.65-57.301l-211.621-126.728l-129.253,207.443%20c38.227,26.239,78.619,49.174,120.74,68.553c39.614,17.529,81.399,29.676,124.238,36.113L2281.347,1543.658z'/%3e%3cpath%20fill='%23F89303'%20d='M1989.341,1382.766c24.192,102.111,78.312,161.199,141.062,167.98l-0.016,0.113l203.912,32.807%20l0.075-0.393c41.153,7.771,86.507-7.063,129.957-48.111c105.716-99.871,159.688-314.781,120.55-480.01%20c-21.63-91.329-67.229-148.155-121.501-164.039l0.024-0.13l-0.705-0.114c-8.302-2.335-16.845-3.707-25.459-4.086l-187.713-30.137%20c-7.968-2.2-16.152-3.515-24.406-3.918l-0.944-0.159l-0.021,0.149c-36.832-1.69-76.282,14.151-114.261,50.031%20C2004.176,1002.625,1950.204,1217.536,1989.341,1382.766z'/%3e%3cpath%20fill='%23FFBC6C'%20d='M2210.054,873.781L2210.054,873.781c88.21,9.125-179.002-7.173-264.099-32.135%20c-55.426-16.262-223.712-75.596-304.416-235.64c-18.581-37.048-31.352-76.735-37.857-117.671l-55.313,14.393l-122.475,1099.278%20c63.896-69.313,173.113-160.629,310.726-153.396c137.608,7.233,369.874,73.473,369.874,73.473L2210.054,873.781z'/%3e%3cpath%20fill='%23F89303'%20d='M1635.297,574.398c93.889,396.36-35.584,911.895-289.188,1151.475%20c-253.6,239.578-535.291,112.482-629.18-283.881c-93.889-396.361,35.586-911.893,289.187-1151.471%20C1259.714,50.939,1541.409,178.037,1635.297,574.398z'/%3e%3cpath%20fill='%23FFBC6C'%20d='M2339.805,1029.947c36.451,153.884-13.814,354.033-112.271,447.047%20c-98.458,93.016-207.822,43.672-244.273-110.213c-36.451-153.883,13.815-354.034,112.272-447.049%20C2193.99,826.72,2303.354,876.064,2339.805,1029.947z'/%3e%3cpath%20fill='%23EBF4FF'%20d='M1507.62,648.178c78.39,330.935-29.712,761.371-241.451,961.404%20c-211.738,200.033-446.935,93.914-525.326-237.021c-78.388-330.936,29.714-761.371,241.451-961.405%20C1194.033,211.123,1429.23,317.24,1507.62,648.178z'/%3e%3cpath%20fill='%23FFFFFF'%20d='M1532.6,845.619l-377.64-2.486l-62.369,334.315l370.351,107.835%20C1512.638,1144.166,1536.243,995.185,1532.6,845.619z'/%3e%3cpath%20fill='%23F89303'%20d='M1216.62,923.086c18.892,79.75-7.158,183.477-58.185,231.684%20c-51.026,48.204-107.703,22.631-126.596-57.119c-18.891-79.749,7.162-183.479,58.188-231.682%20C1141.052,817.764,1197.73,843.337,1216.62,923.086z'/%3e%3cpath%20fill='%23FFFFFF'%20d='M1165.02,948.964c13.027,55.003-4.939,126.545-40.131,159.791c-35.192,33.247-74.283,15.611-87.313-39.394%20c-13.03-55.003,4.938-126.544,40.132-159.791C1112.896,876.322,1151.988,893.961,1165.02,948.964z'/%3e%3cpath%20fill='%23F89303'%20d='M1113.771,976.396c6.377,26.927-2.416,61.948-19.646,78.227c-17.228,16.272-36.365,7.639-42.744-19.286%20c-6.377-26.926,2.418-61.949,19.646-78.225C1088.256,940.836,1107.395,949.47,1113.771,976.396z'/%3e%3cpath%20fill='%23FFBC6C'%20d='M1837.002,2127.104c-16.785,20.093-66.761,5.992-111.625-31.491%20c-44.862-37.482-67.623-84.154-50.837-104.244c16.782-20.09,66.761-5.992,111.624,31.49%20C1831.027,2060.344,1853.786,2107.016,1837.002,2127.104z'/%3e%3c/g%3e%3c/g%3e%3c/svg%3e";
