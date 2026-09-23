import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_order.dart';

abstract class NumerologyRepository {
  /// Creates a numerology request and its payment order.
  ResultFuture<NumerologyOrder> submitConsultation({
    required String firstName,
    required String lastName,
    required String day,
    required String month,
    required String year,
    required String mobile,
    required String email,
    required String serviceType,
    required String paymentGateway,
    String? purchaseNumber,
  });

  /// Confirms a paid numerology request. Returns the server's message.
  ResultFuture<String> verifyPayment({
    required String numerologyId,
    required String paymentId,
    required String paymentGateway,
  });
}
