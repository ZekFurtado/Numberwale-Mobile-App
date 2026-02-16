import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/src/numerology/presentation/bloc/numerology_bloc.dart';

class NumerologyPage extends StatelessWidget {
  const NumerologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<NumerologyBloc>(),
      child: const _NumerologyView(),
    );
  }
}

class _NumerologyView extends StatefulWidget {
  const _NumerologyView();

  @override
  State<_NumerologyView> createState() => _NumerologyViewState();
}

class _NumerologyViewState extends State<_NumerologyView> {
  final _formKey = GlobalKey<FormState>();

  // Personal details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _selectedGender;

  // Birth details
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();
  String _meridian = 'AM';

  // Birthplace & language
  final _birthPlaceController = TextEditingController();
  String? _selectedLanguage;

  // Contact details
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  // Purchase number (optional)
  final _purchaseNumberController = TextEditingController();

  static const List<String> _genders = ['male', 'female', 'other'];
  static const List<String> _languages = [
    'english',
    'hindi',
    'marathi',
    'gujarati',
    'tamil',
    'telugu',
    'kannada',
    'bengali',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _birthPlaceController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purchaseNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<NumerologyBloc>().add(SubmitNumerologyConsultationEvent(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          gender: _selectedGender!,
          day: _dayController.text.trim(),
          month: _monthController.text.trim(),
          year: _yearController.text.trim(),
          hours: _hoursController.text.trim(),
          minutes: _minutesController.text.trim(),
          meridian: _meridian,
          birthPlace: _birthPlaceController.text.trim(),
          language: _selectedLanguage!,
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          purchaseNumber: _purchaseNumberController.text.trim().isEmpty
              ? null
              : _purchaseNumberController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Numerology Consultation'),
        centerTitle: true,
      ),
      body: BlocConsumer<NumerologyBloc, NumerologyState>(
        listener: (context, state) {
          if (state is NumerologySubmitted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Request Submitted'),
                content: Text(state.message),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is NumerologyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is NumerologyLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // ─── Personal Details Section ───────────────────────────
                  _SectionHeader(
                    icon: Icons.person_outline,
                    title: 'Personal Details',
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'First name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Last name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                      prefixIcon: Icon(Icons.wc_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _genders
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                  g[0].toUpperCase() + g.substring(1)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Please select a gender' : null,
                  ),
                  const SizedBox(height: 24),

                  // ─── Birth Details Section ──────────────────────────────
                  _SectionHeader(
                    icon: Icons.cake_outlined,
                    title: 'Birth Details',
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  // Day / Month / Year
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dayController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: const InputDecoration(
                            labelText: 'Day *',
                            border: OutlineInputBorder(),
                            counterText: '',
                            hintText: '1-31',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final day = int.tryParse(v.trim());
                            if (day == null || day < 1 || day > 31) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _monthController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: const InputDecoration(
                            labelText: 'Month *',
                            border: OutlineInputBorder(),
                            counterText: '',
                            hintText: '1-12',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final month = int.tryParse(v.trim());
                            if (month == null || month < 1 || month > 12) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: const InputDecoration(
                            labelText: 'Year *',
                            border: OutlineInputBorder(),
                            counterText: '',
                            hintText: '1900-2026',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final year = int.tryParse(v.trim());
                            if (year == null ||
                                year < 1900 ||
                                year > 2026) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hours / Minutes / AM-PM
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: const InputDecoration(
                            labelText: 'Hours *',
                            border: OutlineInputBorder(),
                            counterText: '',
                            hintText: '1-12',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final h = int.tryParse(v.trim());
                            if (h == null || h < 1 || h > 12) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _minutesController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: const InputDecoration(
                            labelText: 'Minutes *',
                            border: OutlineInputBorder(),
                            counterText: '',
                            hintText: '00-59',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final m = int.tryParse(v.trim());
                            if (m == null || m < 0 || m > 59) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // AM/PM SegmentedButton
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AM / PM',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'AM',
                                  label: Text('AM'),
                                ),
                                ButtonSegment(
                                  value: 'PM',
                                  label: Text('PM'),
                                ),
                              ],
                              selected: {_meridian},
                              onSelectionChanged: (selected) {
                                setState(() {
                                  _meridian = selected.first;
                                });
                              },
                              style: SegmentedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Birthplace
                  TextFormField(
                    controller: _birthPlaceController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Birthplace *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                      hintText: 'City, State',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Birthplace is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Language
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Language *',
                      prefixIcon: Icon(Icons.language_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _languages
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(
                                  lang[0].toUpperCase() + lang.substring(1)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Please select a language' : null,
                  ),
                  const SizedBox(height: 24),

                  // ─── Contact Details Section ────────────────────────────
                  _SectionHeader(
                    icon: Icons.contact_phone_outlined,
                    title: 'Contact Details',
                    theme: theme,
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
                  const SizedBox(height: 24),

                  // ─── Purchase Number (optional) ─────────────────────────
                  TextFormField(
                    controller: _purchaseNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Number (Optional)',
                      prefixIcon: Icon(Icons.sim_card_outlined),
                      border: OutlineInputBorder(),
                      hintText: 'Number you wish to purchase (optional)',
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
                        : const Text('Submit Consultation Request'),
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Divider(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          thickness: 1,
        ),
      ],
    );
  }
}
