import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/auth_mode_toggle.dart';
import 'package:numberwale/core/widgets/phone_input_field.dart';
import 'package:numberwale/core/widgets/text_input_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  AuthMode _authMode = AuthMode.email;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  Future<void> _handleRequestOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual request OTP logic with BLoC
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate to OTP verification page
    final contact = _authMode == AuthMode.email
        ? _emailController.text
        : _phoneController.text;

    Navigator.pushNamed(
      context,
      Routes.otpVerification,
      arguments: {
        'contact': contact,
        if (_authMode == AuthMode.email) 'email': _emailController.text,
        'verificationType': 'forgot_password',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Icon
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Reset Password',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Enter your registered email or phone number to receive an OTP for password reset',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Auth mode toggle
                AuthModeToggle(
                  selectedMode: _authMode,
                  onModeChanged: (mode) {
                    setState(() {
                      _authMode = mode;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Email mode
                if (_authMode == AuthMode.email)
                  TextInputField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your registered email',
                    keyboardType: TextInputType.emailAddress,
                    icon: const Icon(Icons.email_outlined),
                    validator: _validateEmail,
                  ),

                // Phone mode
                if (_authMode == AuthMode.phone)
                  PhoneInputField(
                    controller: _phoneController,
                    validator: _validatePhone,
                  ),

                const SizedBox(height: 32),

                // Request OTP button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRequestOTP,
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
                      : const Text('Send OTP'),
                ),
                const SizedBox(height: 24),

                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
