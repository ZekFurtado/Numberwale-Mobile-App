import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/password_input_field.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _handleResetPassword() {
    if (!_formKey.currentState!.validate()) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final otp = args?['otp'] as String? ?? '';

    context.read<AuthenticationBloc>().add(
          ResetPasswordEvent(
            contact: '',
            otp: otp,
            newPassword: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) async {
        if (state is PasswordReset) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: Icon(
                Icons.check_circle,
                size: 64,
                color: theme.colorScheme.tertiary,
              ),
              title: const Text('Password Reset Successful'),
              content: const Text(
                'Your password has been reset successfully. You can now login with your new password.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
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
        final isLoading = state is ResettingPassword;

        return Scaffold(
          appBar: AppBar(title: const Text('Reset Password')),
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
                      Icons.vpn_key,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Create New Password',
                      style: theme.textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your new password must be different from previously used passwords',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    PasswordInputField(
                      controller: _passwordController,
                      labelText: 'New Password',
                      showStrengthIndicator: true,
                      showRequirements: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 24),
                    PasswordInputField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      validator: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Reset Password'),
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
