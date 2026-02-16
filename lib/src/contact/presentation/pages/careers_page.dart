import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/src/contact/presentation/bloc/contact_bloc.dart';

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ContactBloc>(),
      child: const _CareersView(),
    );
  }
}

class _CareersView extends StatefulWidget {
  const _CareersView();

  @override
  State<_CareersView> createState() => _CareersViewState();
}

class _CareersViewState extends State<_CareersView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _resumeController = TextEditingController();
  final _coverLetterController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _resumeController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ContactBloc>().add(SubmitCareerApplicationEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _mobileController.text.trim(),
          resume: _resumeController.text.trim(),
          coverLetter: _coverLetterController.text.trim().isEmpty
              ? null
              : _coverLetterController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Application'),
        centerTitle: true,
      ),
      body: BlocConsumer<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is CareerApplicationSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Your application has been submitted successfully. We will be in touch soon.'),
              ),
            );
            Navigator.pop(context);
          } else if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ContactLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'We\'d love to hear from you. Submit your application and join our team.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

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

                  // Resume
                  TextFormField(
                    controller: _resumeController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Resume (URL or paste content) *',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.description_outlined),
                      ),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      hintText:
                          'Paste your resume content or provide a link (e.g. LinkedIn, Google Drive)',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Resume is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Cover Letter (optional)
                  TextFormField(
                    controller: _coverLetterController,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Cover Letter (Optional)',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.edit_note_outlined),
                      ),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      hintText: 'Tell us why you\'d like to work with us...',
                    ),
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Application'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
