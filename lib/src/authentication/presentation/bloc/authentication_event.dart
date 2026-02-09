part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class SendOTPEvent extends AuthenticationEvent {
  const SendOTPEvent({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOTPEvent extends AuthenticationEvent {
  const VerifyOTPEvent({
    required this.verificationId,
    required this.smsCode,
  });

  final String verificationId;
  final String smsCode;

  @override
  List<Object> get props => [verificationId, smsCode];
}

class VerifyOTPAndCreateUserEvent extends AuthenticationEvent {
  const VerifyOTPAndCreateUserEvent({
    required this.verificationId,
    required this.smsCode,
    required this.fullName,
    this.referralCode,
  });

  final String verificationId;
  final String smsCode;
  final String fullName;
  final String? referralCode;

  @override
  List<Object?> get props => [verificationId, smsCode, fullName, referralCode];
}

class GoogleSignInEvent extends AuthenticationEvent {
  const GoogleSignInEvent();
}

class AppleSignInEvent extends AuthenticationEvent {
  const AppleSignInEvent();
}

class GetUserSessionEvent extends AuthenticationEvent {
  const GetUserSessionEvent();
}

class SignOutUserEvent extends AuthenticationEvent {
  const SignOutUserEvent();
}

class CheckUserSignedInEvent extends AuthenticationEvent {
  const CheckUserSignedInEvent();
}

class DeleteAccountEvent extends AuthenticationEvent {
  const DeleteAccountEvent({this.password});

  final String? password;

  @override
  List<Object?> get props => [password];
}

// Registration Event
class RegisterUserEvent extends AuthenticationEvent {
  const RegisterUserEvent({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.accountType,
    this.companyName,
    this.gstin,
    this.whatsappUpdates = false,
  });

  final String name;
  final String email;
  final String mobile;
  final String password;
  final String accountType; // 'individual' or 'corporate'
  final String? companyName;
  final String? gstin;
  final bool whatsappUpdates;

  @override
  List<Object?> get props => [
        name,
        email,
        mobile,
        password,
        accountType,
        companyName,
        gstin,
        whatsappUpdates,
      ];
}

// Login with Email/Password Event
class LoginWithPasswordEvent extends AuthenticationEvent {
  const LoginWithPasswordEvent({
    required this.contact, // can be email or phone
    required this.password,
  });

  final String contact;
  final String password;

  @override
  List<Object> get props => [contact, password];
}

// Login with Phone/OTP Event (sends OTP)
class LoginWithPhoneEvent extends AuthenticationEvent {
  const LoginWithPhoneEvent({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

// Forgot Password Event (request OTP for password reset)
class ForgotPasswordEvent extends AuthenticationEvent {
  const ForgotPasswordEvent({
    required this.contact, // email or phone
    required this.isEmail,
  });

  final String contact;
  final bool isEmail;

  @override
  List<Object> get props => [contact, isEmail];
}

// Reset Password Event (with OTP verification)
class ResetPasswordEvent extends AuthenticationEvent {
  const ResetPasswordEvent({
    required this.contact,
    required this.otp,
    required this.newPassword,
  });

  final String contact;
  final String otp;
  final String newPassword;

  @override
  List<Object> get props => [contact, otp, newPassword];
}

// Resend OTP Event
class ResendOTPEvent extends AuthenticationEvent {
  const ResendOTPEvent({
    required this.contact,
    required this.isEmail,
  });

  final String contact;
  final bool isEmail;

  @override
  List<Object> get props => [contact, isEmail];
}
