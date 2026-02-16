import 'package:equatable/equatable.dart';

/// Represents a payment gateway available for checkout
class PaymentGateway extends Equatable {
  /// Unique identifier for the gateway (e.g. razorpay, phonepe)
  final String id;

  /// Display name of the gateway
  final String name;

  /// Whether this gateway is currently enabled
  final bool enabled;

  /// Short description of the gateway
  final String description;

  /// Optional URL of the gateway logo
  final String? logoUrl;

  /// Supported payment methods for this gateway (e.g. upi, card, netbanking)
  final List<String> methods;

  const PaymentGateway({
    required this.id,
    required this.name,
    required this.enabled,
    required this.description,
    this.logoUrl,
    required this.methods,
  });

  @override
  List<Object?> get props => [id];
}
