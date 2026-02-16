import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/numerology/domain/usecases/submit_numerology_consultation.dart';

part 'numerology_event.dart';
part 'numerology_state.dart';

class NumerologyBloc extends Bloc<NumerologyEvent, NumerologyState> {
  final SubmitNumerologyConsultation _submitNumerologyConsultation;

  NumerologyBloc({
    required SubmitNumerologyConsultation submitNumerologyConsultation,
  })  : _submitNumerologyConsultation = submitNumerologyConsultation,
        super(const NumerologyInitial()) {
    on<SubmitNumerologyConsultationEvent>(_onSubmitNumerologyConsultation);
  }

  Future<void> _onSubmitNumerologyConsultation(
    SubmitNumerologyConsultationEvent event,
    Emitter<NumerologyState> emit,
  ) async {
    emit(const NumerologyLoading());

    log('NumerologyBloc: submitting consultation for ${event.firstName} ${event.lastName}');

    final result = await _submitNumerologyConsultation(
      NumerologyConsultationParams(
        firstName: event.firstName,
        lastName: event.lastName,
        gender: event.gender,
        day: event.day,
        month: event.month,
        year: event.year,
        hours: event.hours,
        minutes: event.minutes,
        meridian: event.meridian,
        birthPlace: event.birthPlace,
        language: event.language,
        mobile: event.mobile,
        email: event.email,
        purchaseNumber: event.purchaseNumber,
      ),
    );

    result.fold(
      (failure) => emit(NumerologyError(message: failure.message)),
      (_) => emit(const NumerologySubmitted(
        message:
            'Numerology request submitted successfully! We will contact you within 24-48 hours.',
      )),
    );
  }
}
