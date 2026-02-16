import 'package:numberwale/core/utils/typedef.dart';

abstract class ContactRepository {
  ResultVoid submitContact({
    required String name,
    required String email,
    required String mobileNo,
    required String message,
    String? companyName,
    String? type,
  });

  ResultVoid submitCareerApplication({
    required String name,
    required String email,
    required String mobile,
    required String resume,
    String? coverLetter,
  });
}
