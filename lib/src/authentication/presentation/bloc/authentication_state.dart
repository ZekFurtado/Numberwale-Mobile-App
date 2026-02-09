part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

/// The initial state of the Authentication Phase
class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

/// State to be exhibited when OTP is being sent
class SendingOTP extends AuthenticationState {
  const SendingOTP();
}

/// State to be exhibited when OTP has been sent successfully
class OTPSent extends AuthenticationState {
  const OTPSent({required this.verificationId});

  final String verificationId;

  @override
  List<Object> get props => [verificationId];
}

/// State to be exhibited when OTP is being verified
class VerifyingOTP extends AuthenticationState {
  const VerifyingOTP();
}

/// State to be exhibited when a new phone user is being created
class CreatingPhoneUser extends AuthenticationState {
  const CreatingPhoneUser();
}

/// State to be exhibited when a user is signing in with Google
class SigningInGoogleUser extends AuthenticationState {
  const SigningInGoogleUser();
}

/// State to be exhibited when a user is signing in with Apple
class SigningInAppleUser extends AuthenticationState {
  const SigningInAppleUser();
}

class SigningOutUser extends AuthenticationState {
  const SigningOutUser();
}

class FetchingUserSession extends AuthenticationState {
  const FetchingUserSession();
}

/// State to be exhibited when a user has successfully been authenticated
class Authenticated extends AuthenticationState {
  const Authenticated(this.localUser);

  /// The user object returned from Firebase
  final LocalUser localUser;

  @override
  List<Object> get props => [localUser.uid ?? ''];
}

class SignedOut extends AuthenticationState {
  const SignedOut();
}

/// State to be exhibited when an error has occurred while authenticating the
/// user
class AuthenticationError extends AuthenticationState {
  const AuthenticationError({required this.message});

  /// Error message
  final String message;
}

class TogglePasswordVisibility extends AuthenticationState {
  final bool hidePass;

  const TogglePasswordVisibility({required this.hidePass});
}


class CheckingExistingSession extends AuthenticationState {
  const CheckingExistingSession();
}

class CheckingExistingSessionFailure extends AuthenticationState {
  final String? message;

  const CheckingExistingSessionFailure({this.message});

  @override
  List<Object?> get props => [message];
}

class CheckedExistingSession extends AuthenticationState {
  final LocalUser? localUser;

  const CheckedExistingSession({this.localUser});

  @override
  List<Object?> get props => [localUser];
}

class DeletingAccount extends AuthenticationState {
  const DeletingAccount();
}

class AccountDeleted extends AuthenticationState {
  const AccountDeleted();
}

// Registration States
class RegisteringUser extends AuthenticationState {
  const RegisteringUser();
}

class UserRegistered extends AuthenticationState {
  const UserRegistered({
    required this.email,
    required this.mobile,
  });

  final String email;
  final String mobile;

  @override
  List<Object> get props => [email, mobile];
}

// Login States
class LoggingIn extends AuthenticationState {
  const LoggingIn();
}

class LoggedIn extends AuthenticationState {
  const LoggedIn({required this.user});

  final LocalUser user;

  @override
  List<Object> get props => [user];
}

// Forgot Password States
class SendingPasswordResetOTP extends AuthenticationState {
  const SendingPasswordResetOTP();
}

class PasswordResetOTPSent extends AuthenticationState {
  const PasswordResetOTPSent({
    required this.contact,
    required this.verificationId,
  });

  final String contact;
  final String verificationId;

  @override
  List<Object> get props => [contact, verificationId];
}

// Reset Password States
class ResettingPassword extends AuthenticationState {
  const ResettingPassword();
}

class PasswordReset extends AuthenticationState {
  const PasswordReset();
}

// OTP Verification Success
class OTPVerified extends AuthenticationState {
  const OTPVerified({this.user});

  final LocalUser? user;

  @override
  List<Object?> get props => [user];
}
