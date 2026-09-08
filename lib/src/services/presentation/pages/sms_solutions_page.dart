import 'package:flutter/material.dart';
import 'package:numberwale/src/services/presentation/widgets/step_walkthrough.dart';

const _orange = kServiceOrange;
const _bodyGray = kServiceBodyGray;

const _introText =
    'Our SMS Solution platform provides businesses with powerful tools to '
    'reach customers effectively through text messaging. With our intuitive '
    'dashboard, customizable messaging options, and robust analytics, you '
    'can create and manage SMS campaigns that drive engagement and results.';

const _steps = [
  StepItem(
    number: 1,
    title: 'Advanced Dashboard',
    media: NetworkStepImage(
        url: 'https://www.numberwale.com/assets/DASHBOARD-C79HjZ1k.png'),
    text:
        'Get a quick glance over your complete message status, configure '
        'SENDER ID, template in real-time. Check number of credits '
        'available, number of messages sent on same day, weekly, monthly '
        'and previous month. Create an experience that is appealing to '
        'every user.',
  ),
  StepItem(
    number: 2,
    title: 'Customized Messaging',
    media: NetworkStepImage(
        url:
            'https://www.numberwale.com/assets/CUSTOMIZED-MESSAGING-Dgafk39O.png'),
    text:
        'Communicate with your customers on a personal level and deliver '
        'effective messages. Customized messages enables you to send '
        'messages by mentioning custom fields like customer name, mobile '
        'number, message template etc. easily.',
  ),
  StepItem(
    number: 3,
    title: 'Multiple Sender IDs',
    media: NetworkStepImage(
        url: 'https://www.numberwale.com/assets/MULTIPLE-SENDER-UsLTvvDA.png'),
    text:
        'Create and manage multiple sender IDs with our user-friendly web '
        'portal. Improve brand awareness and promote your brand with sender '
        'ID that your customer is familiar with.',
  ),
  StepItem(
    number: 4,
    title: 'Delivery Reports & Analytics',
    media: NetworkStepImage(
        url: 'https://www.numberwale.com/assets/ANALYTICS-7cbVteqO.png'),
    text:
        'Receive reports real-time about message status applying filters '
        'status wise. Graphical Analytics allows you to view the number of '
        'messages sent, delivered on a hourly, daily, weekly, monthly etc. '
        'basis.',
  ),
  StepItem(
    number: 5,
    title: 'Bulk Contact Upload',
    media: NetworkStepImage(
        url:
            'https://www.numberwale.com/assets/BULK-CONTACT-UPLOAD-Mer8pexV.png'),
    text:
        'Upload and send up to 500K Contact in a single batch through Bulk '
        'Upload. Track the progress of file upload in the progress bar and '
        'get information instantly about pending amount of upload.',
  ),
  StepItem(
    number: 6,
    title: 'Campaign Management',
    media: NetworkStepImage(
        url:
            'https://www.numberwale.com/assets/CAMPAIGN-MANAGEMENT-C1wcjQfd.png'),
    text:
        'Run, manage and monitor your SMS campaigns from a single, '
        'user-friendly dashboard interface. Send messages through panel '
        'request or upload messages to our platform and let us handle the '
        'message delivery.',
  ),
];

/// Mirrors the "SMS Solution" product page at
/// numberwale.com/products/sms-solutions: the orange hero banner and the
/// numbered "how our SMS solution works" walkthrough, laid out for a single
/// mobile column.
class SmsSolutionsPage extends StatelessWidget {
  const SmsSolutionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Solutions'),
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
              const Text(
                'HOW OUR SMS SOLUTION WORKS',
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
              const StepWalkthrough(steps: _steps),
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
            'SMS Solution',
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
              'https://www.numberwale.com/assets/sms-DHwolJV_.png',
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
