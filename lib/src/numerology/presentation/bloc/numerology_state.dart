part of 'numerology_bloc.dart';

abstract class NumerologyState extends Equatable {
  const NumerologyState();

  @override
  List<Object?> get props => [];
}

class NumerologyInitial extends NumerologyState {
  const NumerologyInitial();
}

/// Creating the numerology request + payment order.
class NumerologyLoading extends NumerologyState {
  const NumerologyLoading();
}

/// The request exists and a payment order is waiting to be paid. The page
/// now opens the Razorpay sheet (or the PhonePe hosted page).
class NumerologyOrderCreated extends NumerologyState {
  const NumerologyOrderCreated({
    required this.order,
    required this.paymentGateway,
  });

  final NumerologyOrder order;
  final String paymentGateway;

  @override
  List<Object?> get props => [order, paymentGateway];
}

class NumerologyVerifyingPayment extends NumerologyState {
  const NumerologyVerifyingPayment();
}

class NumerologyPaymentVerified extends NumerologyState {
  const NumerologyPaymentVerified({
    required this.numerologyId,
    required this.message,
  });

  final String numerologyId;
  final String message;

  @override
  List<Object?> get props => [numerologyId, message];
}

class NumerologyError extends NumerologyState {
  final String message;

  const NumerologyError({required this.message});

  @override
  List<Object?> get props => [message];
}
