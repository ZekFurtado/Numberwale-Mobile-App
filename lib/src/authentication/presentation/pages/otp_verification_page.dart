import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/otp_input_field.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  String _otpValue = '';
  bool _hasError = false;
  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendOTP() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual resend OTP logic with BLoC
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = false;
    });

    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully'),
      ),
    );
  }

  Future<void> _handleVerifyOTP(String otp) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // TODO: Implement actual OTP verification logic with BLoC
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Simulate verification
    final isValid = otp == '123456'; // Mock validation

    if (isValid) {
      setState(() {
        _isLoading = false;
      });

      // Navigate based on verification type
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final verificationType = args?['verificationType'] as String?;

      if (verificationType == 'forgot_password') {
        Navigator.pushReplacementNamed(context, Routes.resetPassword);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.appShell,
          (route) => false,
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final contact = args?['contact'] as String? ?? '';
    final email = args?['email'] as String?;

    // Mask contact for display
    String maskedContact = contact;
    if (contact.length >= 4) {
      maskedContact =
          '${contact.substring(0, 2)}${'*' * (contact.length - 4)}${contact.substring(contact.length - 2)}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Icon
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Enter Verification Code',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Instruction text
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

              // OTP Input
              OTPInputField(
                onCompleted: _handleVerifyOTP,
                onChanged: (value) {
                  setState(() {
                    _otpValue = value;
                    _hasError = false;
                  });
                },
                hasError: _hasError,
              ),
              const SizedBox(height: 32),

              // Resend OTP section
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
                      onPressed: _isLoading ? null : _handleResendOTP,
                      child: const Text('Resend'),
                    ),
                  ],
                ),

              const Spacer(),

              // Verify button
              ElevatedButton(
                onPressed: (_isLoading || _otpValue.length != 6)
                    ? null
                    : () => _handleVerifyOTP(_otpValue),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 16),

              // Change number/email button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Change Phone Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
