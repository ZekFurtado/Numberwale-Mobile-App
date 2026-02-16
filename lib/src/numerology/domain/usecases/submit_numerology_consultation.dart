import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/numerology/domain/repositories/numerology_repository.dart';

/// Use case to submit a numerology consultation request
class SubmitNumerologyConsultation
    extends UseCaseWithParams<void, NumerologyConsultationParams> {
  final NumerologyRepository _repository;

  SubmitNumerologyConsultation(this._repository);

  @override
  ResultVoid call(NumerologyConsultationParams params) {
    return _repository.submitConsultation(
      firstName: params.firstName,
      lastName: params.lastName,
      gender: params.gender,
      day: params.day,
      month: params.month,
      year: params.year,
      hours: params.hours,
      minutes: params.minutes,
      meridian: params.meridian,
      birthPlace: params.birthPlace,
      language: params.language,
      mobile: params.mobile,
      email: params.email,
      purchaseNumber: params.purchaseNumber,
    );
  }
}

class NumerologyConsultationParams extends Equatable {
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

  const NumerologyConsultationParams({
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
