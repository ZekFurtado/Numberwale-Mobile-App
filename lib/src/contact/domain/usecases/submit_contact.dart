import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/contact/domain/repositories/contact_repository.dart';

class SubmitContactParams extends Equatable {
  final String name;
  final String email;
  final String mobileNo;
  final String message;
  final String? companyName;
  final String? type;

  const SubmitContactParams({
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.message,
    this.companyName,
    this.type,
  });

  @override
  List<Object?> get props => [name, email, mobileNo, message, companyName, type];
}

class SubmitContact extends UseCaseWithParams<void, SubmitContactParams> {
  final ContactRepository _repository;

  SubmitContact(this._repository);

  @override
  ResultVoid call(SubmitContactParams params) {
    return _repository.submitContact(
      name: params.name,
      email: params.email,
      mobileNo: params.mobileNo,
      message: params.message,
      companyName: params.companyName,
      type: params.type,
    );
  }
}
