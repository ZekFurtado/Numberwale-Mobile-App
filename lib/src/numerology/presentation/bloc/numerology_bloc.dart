import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_order.dart';
import 'package:numberwale/src/numerology/domain/usecases/submit_numerology_consultation.dart';
import 'package:numberwale/src/numerology/domain/usecases/verify_numerology_payment.dart';

part 'numerology_event.dart';
part 'numerology_state.dart';

class NumerologyBloc extends Bloc<NumerologyEvent, NumerologyState> {
  final SubmitNumerologyConsultation _submitNumerologyConsultation;
  final VerifyNumerologyPayment _verifyNumerologyPayment;

  NumerologyBloc({
    required SubmitNumerologyConsultation submitNumerologyConsultation,
    required VerifyNumerologyPayment verifyNumerologyPayment,
  })  : _submitNumerologyConsultation = submitNumerologyConsultation,
        _verifyNumerologyPayment = verifyNumerologyPayment,
        super(const NumerologyInitial()) {
    on<SubmitNumerologyConsultationEvent>(_onSubmitNumerologyConsultation);
    on<VerifyNumerologyPaymentEvent>(_onVerifyNumerologyPayment);
    on<ResetNumerologyEvent>(
      (_, emit) => emit(const NumerologyInitial()),
    );
  }

  Future<void> _onSubmitNumerologyConsultation(
    SubmitNumerologyConsultationEvent event,
    Emitter<NumerologyState> emit,
  ) async {
    emit(const NumerologyLoading());

    log('NumerologyBloc: submitting ${event.serviceType} '
        'for ${event.firstName} ${event.lastName}');

    final result = await _submitNumerologyConsultation(
      NumerologyConsultationParams(
        firstName: event.firstName,
        lastName: event.lastName,
        day: event.day,
        month: event.month,
        year: event.year,
        mobile: event.mobile,
        email: event.email,
        serviceType: event.serviceType,
        paymentGateway: event.paymentGateway,
        purchaseNumber: event.purchaseNumber,
      ),
    );

    result.fold(
      (failure) => emit(NumerologyError(message: failure.message)),
      (order) => emit(NumerologyOrderCreated(
        order: order,
        paymentGateway: event.paymentGateway,
      )),
    );
  }

  Future<void> _onVerifyNumerologyPayment(
    VerifyNumerologyPaymentEvent event,
    Emitter<NumerologyState> emit,
  ) async {
    emit(const NumerologyVerifyingPayment());

    final result = await _verifyNumerologyPayment(
      VerifyNumerologyPaymentParams(
        numerologyId: event.numerologyId,
        paymentId: event.paymentId,
        paymentGateway: event.paymentGateway,
      ),
    );

    result.fold(
      (failure) => emit(NumerologyError(message: failure.message)),
      (message) => emit(NumerologyPaymentVerified(
        numerologyId: event.numerologyId,
        message: message,
      )),
    );
  }
}
