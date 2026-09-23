import 'package:equatable/equatable.dart';
import 'package:numberwale/src/orders/domain/entities/order_payment.dart';
import 'package:numberwale/src/orders/domain/entities/order_product.dart';

/// Represents a customer order in the app
class Order extends Equatable {
  /// Unique database identifier for this order
  final String? id;

  /// Human-readable order number (e.g. "ORD-2026-001")
  final String orderNumber;

  /// Overall order status (e.g. "completed", "pending", "cancelled")
  final String status;

  /// List of products included in this order
  final List<OrderProduct> products;

  /// Payment details for this order
  final OrderPayment? payment;

  /// Timestamp when this order was created
  final DateTime? createdAt;

  /// Address ID linked to this order, if any
  final String? addressId;

  const Order({
    this.id,
    required this.orderNumber,
    required this.status,
    required this.products,
    this.payment,
    this.createdAt,
    this.addressId,
  });

  /// Payment states that mean money actually changed hands.
  static const _paidStatuses = {
    'completed',
    'paid',
    'success',
    'successful',
    'captured',
  };

  /// True once payment has gone through.
  ///
  /// `POST /cart/checkout` creates the order *before* the payment sheet is
  /// even shown, so a cancelled or failed payment leaves an order behind with
  /// no successful payment attached. Those aren't purchases and shouldn't be
  /// presented to the customer as orders.
  bool get isPaid {
    final status = payment?.status.toLowerCase().trim();
    if (status == null || status.isEmpty) return false;
    return _paidStatuses.contains(status);
  }

  @override
  List<Object?> get props => [id, orderNumber];
}
