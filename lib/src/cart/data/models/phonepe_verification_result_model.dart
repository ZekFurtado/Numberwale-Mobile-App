import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/cart/domain/entities/phonepe_verification_result.dart';

class PhonePeVerificationResultModel extends PhonePeVerificationResult {
  const PhonePeVerificationResultModel({
    required super.status,
    required super.message,
    super.orderId,
    super.orderNumber,
  });

  factory PhonePeVerificationResultModel.fromMap(DataMap map) {
    final statusStr = map['paymentStatus'] as String? ?? 'PENDING';
    final status = switch (statusStr) {
      'COMPLETED' => PhonePePaymentStatus.completed,
      'FAILED' => PhonePePaymentStatus.failed,
      _ => PhonePePaymentStatus.pending,
    };

    final data = map['data'] as DataMap?;
    final order = data?['order'] as DataMap?;

    return PhonePeVerificationResultModel(
      status: status,
      message: map['message'] as String? ??
          (status == PhonePePaymentStatus.completed
              ? 'Payment completed'
              : 'Payment is still being processed'),
      orderId: order?['_id'] as String?,
      orderNumber: order?['orderNumber'] as String?,
    );
  }
}
