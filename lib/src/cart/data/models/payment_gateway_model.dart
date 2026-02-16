import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/payment_gateway.dart';

/// The model of the PaymentGateway class. This model extends the entity and
/// adds additional features to it (serialization/deserialization). This is
/// the model that will be used throughout the data layer.
class PaymentGatewayModel extends PaymentGateway {
  const PaymentGatewayModel({
    required super.id,
    required super.name,
    required super.enabled,
    required super.description,
    super.logoUrl,
    required super.methods,
  });

  /// Creates a PaymentGatewayModel from a Map
  factory PaymentGatewayModel.fromMap(DataMap map) {
    final rawMethods = map['methods'] as List<dynamic>? ?? [];
    final methods = rawMethods.map((m) => m.toString()).toList();

    return PaymentGatewayModel(
      id: map['id'] as String? ?? map['_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? true,
      description: map['description'] as String? ?? '',
      logoUrl: map['logoUrl'] as String? ?? map['logo_url'] as String?,
      methods: methods,
    );
  }
}
