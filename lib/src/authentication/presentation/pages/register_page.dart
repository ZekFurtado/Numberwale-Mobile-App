import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/password_input_field.dart';
import 'package:numberwale/core/widgets/phone_input_field.dart';
import 'package:numberwale/core/widgets/text_input_field.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';

enum AccountType { individual, corporate }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _gstinController = TextEditingController();

  AccountType _accountType = AccountType.individual;
  bool _whatsappUpdates = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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
      return 'Please enter your mobile number';
    }
    if (value.length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateCompanyName(String? value) {
    if (_accountType == AccountType.corporate) {
      if (value == null || value.isEmpty) {
        return 'Please enter company name';
      }
    }
    return null;
  }

  String? _validateGSTIN(String? value) {
    if (_accountType == AccountType.corporate) {
      if (value == null || value.isEmpty) {
        return 'Please enter GSTIN';
      }
      // Basic GSTIN validation (15 characters)
      if (value.length != 15) {
        return 'GSTIN must be 15 characters';
      }
    }
    return null;
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
        ),
      );
      return;
    }

    context.read<AuthenticationBloc>().add(
          RegisterUserEvent(
            name: _nameController.text,
            email: _emailController.text,
            mobile: _mobileController.text,
            password: _passwordController.text,
            accountType: _accountType == AccountType.individual
                ? 'individual'
                : 'corporate',
            companyName: _companyNameController.text.isEmpty
                ? null
                : _companyNameController.text,
            gstin: _gstinController.text.isEmpty ? null : _gstinController.text,
            whatsappUpdates: _whatsappUpdates,
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
          if (state is UserRegistered) {
            // Navigate to OTP verification page
            Navigator.pushNamed(
              context,
              Routes.otpVerification,
              arguments: {
                'contact': state.mobile,
                'email': state.email,
                'verificationType': 'registration',
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
          final isLoading = state is RegisteringUser;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Create Account'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome text
                Text(
                  'Register',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Account Type Toggle
                Text(
                  'Account Type',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AccountTypeButton(
                          label: 'Individual',
                          isSelected: _accountType == AccountType.individual,
                          onTap: () {
                            setState(() {
                              _accountType = AccountType.individual;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _AccountTypeButton(
                          label: 'Corporate',
                          isSelected: _accountType == AccountType.corporate,
                          onTap: () {
                            setState(() {
                              _accountType = AccountType.corporate;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                TextInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  icon: const Icon(Icons.person_outline),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                // Email
                TextInputField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  icon: const Icon(Icons.email_outlined),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                // Mobile
                PhoneInputField(
                  controller: _mobileController,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),

                // Corporate fields
                if (_accountType == AccountType.corporate) ...[
                  TextInputField(
                    controller: _companyNameController,
                    label: 'Company Name',
                    hintText: 'Enter company name',
                    icon: const Icon(Icons.business_outlined),
                    validator: _validateCompanyName,
                  ),
                  const SizedBox(height: 16),
                  TextInputField(
                    controller: _gstinController,
                    label: 'GSTIN',
                    hintText: 'Enter GSTIN',
                    icon: const Icon(Icons.receipt_outlined),
                    validator: _validateGSTIN,
                  ),
                  const SizedBox(height: 16),
                ],

                // Password
                PasswordInputField(
                  controller: _passwordController,
                  labelText: 'Password',
                  showStrengthIndicator: true,
                  showRequirements: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                PasswordInputField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),

                // WhatsApp updates checkbox
                CheckboxListTile(
                  value: _whatsappUpdates,
                  onChanged: (value) {
                    setState(() {
                      _whatsappUpdates = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Receive updates on WhatsApp',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

                // Terms checkbox
                CheckboxListTile(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Text(
                        'I accept the ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.termsAndConditions);
                        },
                        child: Text(
                          'Terms & Conditions',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Register button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister,
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
                      : const Text('Register'),
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
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
        },
      ),
    );
  }
}

class _AccountTypeButton extends StatelessWidget {
  const _AccountTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
