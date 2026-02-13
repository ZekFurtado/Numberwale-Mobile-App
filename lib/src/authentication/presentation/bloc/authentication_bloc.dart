import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:numberwale/src/authentication/domain/entities/local_user.dart';
import 'package:numberwale/src/authentication/domain/usecases/forgot_password.dart';
import 'package:numberwale/src/authentication/domain/usecases/login.dart';
import 'package:numberwale/src/authentication/domain/usecases/register.dart';
import 'package:numberwale/src/authentication/domain/usecases/resend_otp.dart';
import 'package:numberwale/src/authentication/domain/usecases/reset_password.dart';
import 'package:numberwale/src/authentication/domain/usecases/sign_in.dart';
import 'package:numberwale/src/authentication/domain/usecases/sign_out.dart';
import 'package:numberwale/src/authentication/domain/usecases/verify_otp.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required SignOutUseCase signOutUser,
    required Register register,
    required Login login,
    required SignIn signIn,
    required VerifyOtp verifyOtp,
    required ForgotPassword forgotPassword,
    required ResetPassword resetPassword,
    required ResendOtp resendOtp,
  }) : _signOutUseCase = signOutUser,
       _registerUseCase = register,
       _loginUseCase = login,
       _signInUseCase = signIn,
       _verifyOtpUseCase = verifyOtp,
       _forgotPasswordUseCase = forgotPassword,
       _resetPasswordUseCase = resetPassword,
       _resendOtpUseCase = resendOtp,
       super(const AuthenticationInitial()) {
    on<SignOutUserEvent>(_signOutUserEventHandler);
    on<RegisterUserEvent>(_registerUserEventHandler);
    on<LoginWithPasswordEvent>(_loginWithPasswordEventHandler);
    on<LoginWithPhoneEvent>(_loginWithPhoneEventHandler);
    on<VerifyOTPEvent>(_verifyOTPEventHandler);
    on<ForgotPasswordEvent>(_forgotPasswordEventHandler);
    on<ResetPasswordEvent>(_resetPasswordEventHandler);
    on<ResendOTPEvent>(_resendOTPEventHandler);
  }

  final SignOutUseCase _signOutUseCase;
  final Register _registerUseCase;
  final Login _loginUseCase;
  final SignIn _signInUseCase;
  final VerifyOtp _verifyOtpUseCase;
  final ForgotPassword _forgotPasswordUseCase;
  final ResetPassword _resetPasswordUseCase;
  final ResendOtp _resendOtpUseCase;

  // Store contact info for OTP verification
  String? _lastEmail;
  String? _lastMobile;

  Future<void> _signOutUserEventHandler(
    SignOutUserEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const SigningOutUser());

    final result = await _signOutUseCase();

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (visitor) => emit(const SignedOut()),
    );
  }

  Future<void> _registerUserEventHandler(
    RegisterUserEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const RegisteringUser());

    final result = await _registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
        mobile: event.mobile,
        accountType: event.accountType,
        getWhatsappUpdate: event.whatsappUpdates,
        companyName: event.companyName,
        gstinNo: event.gstin,
      ),
    );

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (data) {
        // Store for OTP verification
        _lastEmail = event.email;
        _lastMobile = event.mobile;
        emit(UserRegistered(email: event.email, mobile: event.mobile));
      },
    );
  }

  Future<void> _loginWithPasswordEventHandler(
    LoginWithPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const LoggingIn());

    final result = await _loginUseCase(
      LoginParams(contact: event.contact, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (user) => emit(LoggedIn(user: user)),
    );
  }

  Future<void> _loginWithPhoneEventHandler(
    LoginWithPhoneEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const SendingOTP());

    final result = await _signInUseCase(
      SignInParams(mobile: event.phoneNumber),
    );

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (data) {
        // Store for OTP verification
        _lastMobile = event.phoneNumber;
        emit(const OTPSent(verificationId: 'otp_sent_via_sms'));
      },
    );
  }

  Future<void> _verifyOTPEventHandler(
    VerifyOTPEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const VerifyingOTP());

    final result = await _verifyOtpUseCase(
      VerifyOtpParams(
        email: _lastEmail,
        mobile: _lastMobile,
        otp: event.smsCode,
      ),
    );

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (user) => emit(OTPVerified(user: user)),
    );
  }

  Future<void> _forgotPasswordEventHandler(
    ForgotPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const SendingPasswordResetOTP());

    final result = await _forgotPasswordUseCase(
      ForgotPasswordParams(
        email: event.isEmail ? event.contact : null,
        mobile: !event.isEmail ? event.contact : null,
      ),
    );

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (data) {
        // Store for password reset
        if (event.isEmail) {
          _lastEmail = event.contact;
        } else {
          _lastMobile = event.contact;
        }
        emit(
          PasswordResetOTPSent(
            contact: event.contact,
            verificationId: 'password_reset_otp_sent',
          ),
        );
      },
    );
  }

  Future<void> _resetPasswordEventHandler(
    ResetPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const ResettingPassword());

    final result = await _resetPasswordUseCase(
      ResetPasswordParams(
        email: _lastEmail,
        mobile: _lastMobile,
        otp: event.otp,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (user) => emit(const PasswordReset()),
    );
  }

  Future<void> _resendOTPEventHandler(
    ResendOTPEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const SendingOTP());

    final result = await _resendOtpUseCase(
      ResendOtpParams(
        email: event.isEmail ? event.contact : null,
        mobile: !event.isEmail ? event.contact : null,
      ),
    );

    result.fold(
      (failure) => emit(AuthenticationError(message: failure.message)),
      (data) {
        // Update stored contact info
        if (event.isEmail) {
          _lastEmail = event.contact;
        } else {
          _lastMobile = event.contact;
        }
        emit(const OTPSent(verificationId: 'otp_resent'));
      },
    );
  }
}
