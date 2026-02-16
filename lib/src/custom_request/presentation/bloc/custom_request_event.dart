part of 'custom_request_bloc.dart';

abstract class CustomRequestEvent extends Equatable {
  const CustomRequestEvent();

  @override
  List<Object?> get props => [];
}

class SubmitCustomRequestEvent extends CustomRequestEvent {
  final String requested;
  final String category;
  final String? userId;
  final String? name;
  final String? email;
  final String? mobileNo;
  final String? city;
  final String? phoneword;

  const SubmitCustomRequestEvent({
    required this.requested,
    required this.category,
    this.userId,
    this.name,
    this.email,
    this.mobileNo,
    this.city,
    this.phoneword,
  });

  @override
  List<Object?> get props => [
        requested,
        category,
        userId,
        name,
        email,
        mobileNo,
        city,
        phoneword,
      ];
}

class VerifyCustomRequestOtpEvent extends CustomRequestEvent {
  final String customizeNumberId;
  final String otp;

  const VerifyCustomRequestOtpEvent({
    required this.customizeNumberId,
    required this.otp,
  });

  @override
  List<Object?> get props => [customizeNumberId, otp];
}
