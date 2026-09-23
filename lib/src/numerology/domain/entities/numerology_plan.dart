import 'package:equatable/equatable.dart';

/// One of the three purchasable numerology report packages.
///
/// [serviceType] is the value `POST /api/v1/numerology` expects — the backend
/// rejects the request without it (along with `paymentGateway`).
class NumerologyPlan extends Equatable {
  const NumerologyPlan({
    required this.serviceType,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.basePrice,
    required this.gst,
    required this.originalPrice,
    required this.discountLabel,
    required this.features,
    required this.buttonText,
    required this.requiresAnalyzeNumber,
    this.benefitsLabel,
    this.bestFor = const [],
  });

  /// `analyze_number`, `new_number_guidance` or `both_reports`.
  final String serviceType;

  final String badge;
  final String title;
  final String subtitle;

  /// Payable amount in rupees, GST included.
  final int price;
  final int basePrice;
  final int gst;
  final int originalPrice;
  final String discountLabel;

  final List<String> features;
  final String buttonText;

  /// When true the customer must supply the mobile number to be analysed.
  final bool requiresAnalyzeNumber;

  final String? benefitsLabel;
  final List<String> bestFor;

  static const analyzeNumber = NumerologyPlan(
    serviceType: 'analyze_number',
    badge: 'CURRENT NUMBER',
    title: 'Existing Mobile Number Analyze',
    subtitle: 'Numerology Analysis',
    price: 299,
    basePrice: 254,
    gst: 45,
    originalPrice: 500,
    discountLabel: '40% OFF',
    features: [
      'Numerology score of your current mobile number',
      'Positive & negative number vibrations',
      'Relationship & compatibility insights',
      'Career & business influence analysis',
      'Relationship impact report',
      'Financial energy alignment',
    ],
    buttonText: 'Analyze My Current Number',
    requiresAnalyzeNumber: true,
  );

  static const newNumberGuidance = NumerologyPlan(
    serviceType: 'new_number_guidance',
    badge: 'NEW NUMBER',
    title: 'New Number Guide Report',
    subtitle: 'Mobile Number Suggestion',
    price: 399,
    basePrice: 338,
    gst: 61,
    originalPrice: 500,
    discountLabel: '20% OFF',
    features: [
      'Customized lucky number selection',
      'Wealth & career alignment',
      'Compatible digit combinations',
      'Financial energy alignment',
    ],
    buttonText: 'Find My Lucky Number',
    requiresAnalyzeNumber: false,
  );

  static const bothReports = NumerologyPlan(
    serviceType: 'both_reports',
    badge: 'BOTH REPORTS',
    title: 'Combo Mobile Number Report',
    subtitle: 'New + Existing Mobile Number (Both Report)',
    price: 499,
    basePrice: 423,
    gst: 76,
    originalPrice: 999,
    discountLabel: 'Best Value',
    features: [
      'Analyze existing mobile number',
      'Receive personalized new number insights',
      'Detailed numerology report explain',
      'Lo Shu Grid Analysis',
      'Compatibility Score',
      'Remedial Suggestions',
    ],
    buttonText: 'Get Combo Reports',
    requiresAnalyzeNumber: true,
    benefitsLabel: 'Combo Benefits',
    bestFor: [
      'Business owners',
      'Professionals',
      'Entrepreneurs',
      'People planning number upgrade',
    ],
  );

  static const List<NumerologyPlan> all = [
    analyzeNumber,
    newNumberGuidance,
    bothReports,
  ];

  @override
  List<Object?> get props => [serviceType];
}
