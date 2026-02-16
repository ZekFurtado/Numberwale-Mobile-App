part of 'numerology_bloc.dart';

abstract class NumerologyEvent extends Equatable {
  const NumerologyEvent();

  @override
  List<Object?> get props => [];
}

class SubmitNumerologyConsultationEvent extends NumerologyEvent {
  final String firstName;
  final String lastName;
  final String gender;
  final String day;
  final String month;
  final String year;
  final String hours;
  final String minutes;
  final String meridian;
  final String birthPlace;
  final String language;
  final String mobile;
  final String email;
  final String? purchaseNumber;

  const SubmitNumerologyConsultationEvent({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.day,
    required this.month,
    required this.year,
    required this.hours,
    required this.minutes,
    required this.meridian,
    required this.birthPlace,
    required this.language,
    required this.mobile,
    required this.email,
    this.purchaseNumber,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        gender,
        day,
        month,
        year,
        hours,
        minutes,
        meridian,
        birthPlace,
        language,
        mobile,
        email,
        purchaseNumber,
      ];
}
