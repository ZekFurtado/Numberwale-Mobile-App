import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/auth_mode_toggle.dart';
import 'package:numberwale/core/widgets/phone_input_field.dart';
import 'package:numberwale/core/widgets/text_input_field.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    if (value.length != 10) return 'Please enter a valid 10-digit phone number';
    return null;
  }

  void _handleRequestOTP() {
    if (!_formKey.currentState!.validate()) return;

    final isEmail = _authMode == AuthMode.email;
    context.read<AuthenticationBloc>().add(
          ForgotPasswordEvent(
            contact: isEmail ? _emailController.text : _phoneController.text,
            isEmail: isEmail,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is PasswordResetOTPSent) {
          final isEmail = _authMode == AuthMode.email;
          final contact =
              isEmail ? _emailController.text : _phoneController.text;
          Navigator.pushNamed(
            context,
            Routes.otpVerification,
            arguments: {
              'contact': contact,
              if (isEmail) 'email': _emailController.text,
              'verificationType': 'forgot_password',
            },
          );
        } else if (state is AuthenticationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SendingPasswordResetOTP;

        return Scaffold(
          appBar: AppBar(title: const Text('Forgot Password')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Reset Password',
                      style: theme.textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter your registered email or phone number to receive an OTP for password reset',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    AuthModeToggle(
                      selectedMode: _authMode,
                      onModeChanged: (mode) =>
                          setState(() => _authMode = mode),
                    ),
                    const SizedBox(height: 24),
                    if (_authMode == AuthMode.email)
                      TextInputField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter your registered email',
                        keyboardType: TextInputType.emailAddress,
                        icon: const Icon(Icons.email_outlined),
                        validator: _validateEmail,
                      ),
                    if (_authMode == AuthMode.phone)
                      PhoneInputField(
                        controller: _phoneController,
                        validator: _validatePhone,
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleRequestOTP,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send OTP'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
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
      },
    );
  }
}
