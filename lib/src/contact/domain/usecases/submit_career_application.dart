import 'package:equatable/equatable.dart';
import 'package:numberwale/core/usecases/usecase.dart';
import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/contact/domain/repositories/contact_repository.dart';

class SubmitCareerApplicationParams extends Equatable {
  final String name;
  final String email;
  final String mobile;
  final String resume;
  final String? coverLetter;

  const SubmitCareerApplicationParams({
    required this.name,
    required this.email,
    required this.mobile,
    required this.resume,
    this.coverLetter,
  });

  @override
  List<Object?> get props => [name, email, mobile, resume, coverLetter];
}

class SubmitCareerApplication
    extends UseCaseWithParams<void, SubmitCareerApplicationParams> {
  final ContactRepository _repository;

  SubmitCareerApplication(this._repository);

  @override
  ResultVoid call(SubmitCareerApplicationParams params) {
    return _repository.submitCareerApplication(
      name: params.name,
      email: params.email,
      mobile: params.mobile,
      resume: params.resume,
      coverLetter: params.coverLetter,
    );
  }
}
