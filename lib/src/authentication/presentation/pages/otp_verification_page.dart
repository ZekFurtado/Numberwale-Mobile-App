import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/otp_input_field.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:smart_auth/smart_auth.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  String _otpValue = '';
  bool _hasError = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  final _smartAuth = SmartAuth.instance;
  final _otpAutoFillController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _listenForOtpAutofill();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _smartAuth.removeUserConsentApiListener();
    _otpAutoFillController.close();
    super.dispose();
  }

  // Listens for the incoming OTP SMS via Android's SMS User Consent API.
  // This triggers a system dialog asking the user to allow this one message
  // to be read - no SMS permission is declared in the app manifest. On iOS
  // autofill is handled natively via the AutofillHints.oneTimeCode field.
  Future<void> _listenForOtpAutofill() async {
    try {
      final result = await _smartAuth.getSmsWithUserConsentApi();
      if (!mounted) return;
      if (result.hasData) {
        final code = result.requireData.code;
        if (code != null && code.isNotEmpty) {
          _otpAutoFillController.add(code);
        }
      }
    } catch (e) {
      log('SMS autofill unavailable: $e');
    }
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Map<String, dynamic>? get _args =>
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  String get _verificationType => _args?['verificationType'] as String? ?? '';

  void _handleVerifyOTP(String otp) {
    // For forgot password the OTP is verified server-side as part of resetPassword,
    // so just forward it to the reset password page.
    if (_verificationType == 'forgot_password') {
      Navigator.pushReplacementNamed(
        context,
        Routes.resetPassword,
        arguments: {'otp': otp},
      );
      return;
    }

    context
        .read<AuthenticationBloc>()
        .add(VerifyOTPEvent(verificationId: '', smsCode: otp));
  }

  void _handleResendOTP() {
    final args = _args;
    final isEmail =
        _verificationType == 'forgot_password' && args?['email'] != null;
    final contact = isEmail
        ? args!['email'] as String
        : args?['contact'] as String? ?? '';

    context
        .read<AuthenticationBloc>()
        .add(ResendOTPEvent(contact: contact, isEmail: isEmail));
    _startTimer();
    _listenForOtpAutofill();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final contact = args?['contact'] as String? ?? '';
    final email = args?['email'] as String?;

    String maskedContact = contact;
    if (contact.length >= 4) {
      maskedContact =
          '${contact.substring(0, 2)}${'*' * (contact.length - 4)}${contact.substring(contact.length - 2)}';
    }

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is OTPVerified) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.appShell,
            (route) => false,
          );
        } else if (state is AuthenticationError) {
          setState(() => _hasError = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is OTPSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is VerifyingOTP || state is SendingOTP;

        return Scaffold(
          appBar: AppBar(title: const Text('Verify OTP')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Enter Verification Code',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We have sent a 6-digit OTP to',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    maskedContact,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'and $email',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 48),
                  OTPInputField(
                    onCompleted: _handleVerifyOTP,
                    onChanged: (value) {
                      setState(() {
                        _otpValue = value;
                        _hasError = false;
                      });
                    },
                    hasError: _hasError,
                    autoFillStream: _otpAutoFillController.stream,
                  ),
                  const SizedBox(height: 32),
                  if (_secondsRemaining > 0)
                    Text(
                      'Resend OTP in $_secondsRemaining seconds',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: isLoading ? null : _handleResendOTP,
                          child: const Text('Resend'),
                        ),
                      ],
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: (isLoading || _otpValue.length != 6)
                        ? null
                        : () => _handleVerifyOTP(_otpValue),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Change Phone Number'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
