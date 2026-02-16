import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/contact/domain/usecases/submit_career_application.dart';
import 'package:numberwale/src/contact/domain/usecases/submit_contact.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final SubmitContact _submitContact;
  final SubmitCareerApplication _submitCareerApplication;

  ContactBloc({
    required SubmitContact submitContact,
    required SubmitCareerApplication submitCareerApplication,
  })  : _submitContact = submitContact,
        _submitCareerApplication = submitCareerApplication,
        super(const ContactInitial()) {
    on<SubmitContactFormEvent>(_onSubmitContactForm);
    on<SubmitCareerApplicationEvent>(_onSubmitCareerApplication);
  }

  Future<void> _onSubmitContactForm(
    SubmitContactFormEvent event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());

    final result = await _submitContact(SubmitContactParams(
      name: event.name,
      email: event.email,
      mobileNo: event.mobileNo,
      message: event.message,
      companyName: event.companyName,
      type: event.type,
    ));

    result.fold(
      (failure) => emit(ContactError(message: failure.message)),
      (_) => emit(const ContactSubmitted()),
    );
  }

  Future<void> _onSubmitCareerApplication(
    SubmitCareerApplicationEvent event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());

    final result = await _submitCareerApplication(SubmitCareerApplicationParams(
      name: event.name,
      email: event.email,
      mobile: event.mobile,
      resume: event.resume,
      coverLetter: event.coverLetter,
    ));

    result.fold(
      (failure) => emit(ContactError(message: failure.message)),
      (_) => emit(const CareerApplicationSubmitted()),
    );
  }
}
