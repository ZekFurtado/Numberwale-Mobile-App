part of 'numerology_bloc.dart';

abstract class NumerologyEvent extends Equatable {
  const NumerologyEvent();

  @override
  List<Object?> get props => [];
}

class SubmitNumerologyConsultationEvent extends NumerologyEvent {
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

  const SubmitNumerologyConsultationEvent({
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

class VerifyNumerologyPaymentEvent extends NumerologyEvent {
  const VerifyNumerologyPaymentEvent({
    required this.numerologyId,
    required this.paymentId,
    required this.paymentGateway,
  });

  final String numerologyId;
  final String paymentId;
  final String paymentGateway;

  @override
  List<Object?> get props => [numerologyId, paymentId, paymentGateway];
}

/// Returns the bloc to its initial state — used when a payment is cancelled
/// or fails, so the form becomes interactive again.
class ResetNumerologyEvent extends NumerologyEvent {
  const ResetNumerologyEvent();
}
