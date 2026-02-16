import 'package:numberwale/core/utils/typedef.dart';

abstract class NumerologyRepository {
  ResultVoid submitConsultation({
    required String firstName,
    required String lastName,
    required String gender,
    required String day,
    required String month,
    required String year,
    required String hours,
    required String minutes,
    required String meridian,
    required String birthPlace,
    required String language,
    required String mobile,
    required String email,
    String? purchaseNumber,
  });
}
