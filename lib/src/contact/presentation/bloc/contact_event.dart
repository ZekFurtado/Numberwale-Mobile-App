part of 'contact_bloc.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

class SubmitContactFormEvent extends ContactEvent {
  final String name;
  final String email;
  final String mobileNo;
  final String message;
  final String? companyName;
  final String? type;

  const SubmitContactFormEvent({
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

class SubmitCareerApplicationEvent extends ContactEvent {
  final String name;
  final String email;
  final String mobile;
  final String resume;
  final String? coverLetter;

  const SubmitCareerApplicationEvent({
    required this.name,
    required this.email,
    required this.mobile,
    required this.resume,
    this.coverLetter,
  });

  @override
  List<Object?> get props => [name, email, mobile, resume, coverLetter];
}
