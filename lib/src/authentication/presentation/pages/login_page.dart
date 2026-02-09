import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/auth_mode_toggle.dart';
import 'package:numberwale/core/widgets/password_input_field.dart';
import 'package:numberwale/core/widgets/phone_input_field.dart';
import 'package:numberwale/core/widgets/text_input_field.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthMode _authMode = AuthMode.email;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    print(_emailController.text);
    context.read<AuthenticationBloc>().add(
          LoginWithPasswordEvent(
            contact: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  void _handlePhoneLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthenticationBloc>().add(
          LoginWithPhoneEvent(
            phoneNumber: _phoneController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => sl<AuthenticationBloc>(),
      child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          print(state);
          if (state is LoggedIn) {
            // Navigate to app shell on successful login
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.appShell,
              (route) => false,
            );
          } else if (state is OTPSent) {
            // Navigate to OTP verification page
            Navigator.pushNamed(
              context,
              Routes.otpVerification,
              arguments: {
                'contact': _phoneController.text,
                'verificationType': 'login',
                'verificationId': state.verificationId,
              },
            );
          } else if (state is AuthenticationError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading =
              state is LoggingIn || state is SendingOTP;

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Logo
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // Welcome text
                Text(
                  'Welcome Back',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your account',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

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

                // Email/Password mode
                if (_authMode == AuthMode.email) ...[
                  TextInputField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    icon: const Icon(Icons.email_outlined),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  PasswordInputField(
                    controller: _passwordController,
                    labelText: 'Password',
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 12),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.forgotPassword);
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ],

                // Phone/OTP mode
                if (_authMode == AuthMode.phone) ...[
                  PhoneInputField(
                    controller: _phoneController,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 24),

                  // Send OTP button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handlePhoneLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Send OTP'),
                  ),
                ],

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.register);
                      },
                      child: const Text('Register'),
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
      ),
    );
  }
}
