import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/context_extension.dart';
import 'package:numberwale/src/custom_request/presentation/bloc/custom_request_bloc.dart';

class CustomRequestPage extends StatelessWidget {
  const CustomRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CustomRequestBloc>(),
      child: const _CustomRequestView(),
    );
  }
}

class _CustomRequestView extends StatefulWidget {
  const _CustomRequestView();

  @override
  State<_CustomRequestView> createState() => _CustomRequestViewState();
}

class _CustomRequestViewState extends State<_CustomRequestView> {
  // Step 1 form
  final _step1FormKey = GlobalKey<FormState>();
  final _requestedController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _phonewordController = TextEditingController();

  String _selectedCategory = 'request';

  static const List<String> _categories = [
    'numerology',
    'birthday',
    'lucky',
    'phoneword',
    'car',
    'similar',
    'request',
  ];

  // Step 2 form
  final _step2FormKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _requestedController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _phonewordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (!_step1FormKey.currentState!.validate()) return;

    final user = context.currentUser;
    final isGuest = user == null;

    context.read<CustomRequestBloc>().add(SubmitCustomRequestEvent(
          requested: _requestedController.text.trim(),
          category: _selectedCategory,
          userId: isGuest ? null : user.uid,
          name: isGuest ? _nameController.text.trim() : null,
          email: isGuest ? _emailController.text.trim() : null,
          mobileNo: isGuest ? _mobileController.text.trim() : null,
          city: isGuest ? _cityController.text.trim() : null,
          phoneword: _selectedCategory == 'phoneword'
              ? _phonewordController.text.trim()
              : null,
        ));
  }

  void _verifyOtp(String requestId) {
    if (!_step2FormKey.currentState!.validate()) return;
    context.read<CustomRequestBloc>().add(VerifyCustomRequestOtpEvent(
          customizeNumberId: requestId,
          otp: _otpController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Number Request'),
        centerTitle: true,
      ),
      body: BlocConsumer<CustomRequestBloc, CustomRequestState>(
        listener: (context, state) {
          if (state is CustomRequestVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Your custom number request has been verified successfully.'),
              ),
            );
            Navigator.pop(context);
          } else if (state is CustomRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomRequestSubmitted) {
            return _buildStep2(context, theme, state);
          }
          return _buildStep1(context, theme, state);
        },
      ),
    );
  }

  Widget _buildStep1(
      BuildContext context, ThemeData theme, CustomRequestState state) {
    final isLoading = state is CustomRequestLoading;
    final isGuest = context.currentUser == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Step indicator
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Request Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Requested Number Pattern
            TextFormField(
              controller: _requestedController,
              decoration: const InputDecoration(
                labelText: 'Requested Number Pattern *',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
                hintText: 'e.g. 98765XXXXX',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Number pattern is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat[0].toUpperCase() + cat.substring(1),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Phoneword field (only for 'phoneword' category)
            if (_selectedCategory == 'phoneword') ...[
              TextFormField(
                controller: _phonewordController,
                decoration: const InputDecoration(
                  labelText: 'Phoneword *',
                  prefixIcon: Icon(Icons.spellcheck_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. FLOWERS',
                ),
                validator: (v) {
                  if (_selectedCategory == 'phoneword') {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phoneword is required for this category';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Guest-only fields
            if (isGuest) ...[
              Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              Text(
                'Contact Information',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mobile
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Mobile *',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (v.trim().length != 10) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                    return 'Mobile number must contain only digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            FilledButton(
              onPressed: isLoading ? null : _submitRequest,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Next'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(
      BuildContext context, ThemeData theme, CustomRequestSubmitted state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Step indicator
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'OTP Verification',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Success card for submitted request
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Request Submitted',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request ID: ${state.requestId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (state.otpSent) ...[
                    const SizedBox(height: 4),
                    Text(
                      'An OTP has been sent to your registered mobile number.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Enter the 6-digit OTP sent to your mobile number to verify your request.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // OTP field
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
                counterText: '',
                hintText: '------',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'OTP is required';
                }
                if (v.trim().length != 6) {
                  return 'OTP must be 6 digits';
                }
                if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                  return 'OTP must contain only digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            BlocBuilder<CustomRequestBloc, CustomRequestState>(
              builder: (context, verifyState) {
                final isVerifyingOtp = verifyState is CustomRequestVerifying;
                return FilledButton(
                  onPressed: isVerifyingOtp
                      ? null
                      : () => _verifyOtp(state.requestId),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isVerifyingOtp
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
