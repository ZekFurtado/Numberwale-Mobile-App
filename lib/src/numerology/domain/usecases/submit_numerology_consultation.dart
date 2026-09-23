import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_order.dart';
import 'package:numberwale/src/numerology/domain/repositories/numerology_repository.dart';

/// Use case to submit a numerology consultation request. Returns the created
/// request plus the payment order the customer must now pay.
class SubmitNumerologyConsultation
    extends UseCaseWithParams<NumerologyOrder, NumerologyConsultationParams> {
  final NumerologyRepository _repository;

  SubmitNumerologyConsultation(this._repository);

  @override
  ResultFuture<NumerologyOrder> call(NumerologyConsultationParams params) {
    return _repository.submitConsultation(
      firstName: params.firstName,
      lastName: params.lastName,
      day: params.day,
      month: params.month,
      year: params.year,
      mobile: params.mobile,
      email: params.email,
      serviceType: params.serviceType,
      paymentGateway: params.paymentGateway,
      purchaseNumber: params.purchaseNumber,
    );
  }
}

class NumerologyConsultationParams extends Equatable {
  final String firstName;
  final String lastName;
  final String day;
  final String month;
  final String year;
  final String mobile;
  final String email;
  final String serviceType;
  final String paymentGateway;
  final String? purchaseNumber;

  const NumerologyConsultationParams({
    required this.firstName,
    required this.lastName,
    required this.day,
    required this.month,
    required this.year,
    required this.mobile,
    required this.email,
    required this.serviceType,
    required this.paymentGateway,
    this.purchaseNumber,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        day,
        month,
        year,
        mobile,
        email,
        serviceType,
        paymentGateway,
        purchaseNumber,
      ];
}
