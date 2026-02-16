import 'package:equatable/equatable.dart';

/// Represents a single product line item within an order
class OrderProduct extends Equatable {
  /// The mobile number associated with this product
  final String productMobileNumber;

  /// The final price paid for this product
  final double finalPrice;

  /// The activation status of this product (e.g. "activated", "pending")
  final String status;

  const OrderProduct({
    required this.productMobileNumber,
    required this.finalPrice,
    required this.status,
  });

  @override
  List<Object?> get props => [productMobileNumber];
}
