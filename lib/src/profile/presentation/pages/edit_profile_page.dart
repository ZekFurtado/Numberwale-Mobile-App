import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/src/profile/presentation/bloc/profile_bloc.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProfileBloc>()..add(const LoadProfileEvent()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _companyController;
  late final TextEditingController _gstController;
  bool _getWhatsappUpdate = false;
  String _accountType = 'Individual';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _companyController = TextEditingController();
    _gstController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _companyController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _populateFields(ProfileLoaded state) {
    final p = state.profile;
    _nameController.text = p.name;
    _emailController.text = p.email;
    _mobileController.text = p.mobile;
    _companyController.text = p.companyName ?? '';
    _gstController.text = p.gstinNo ?? '';
    _getWhatsappUpdate = p.getWhatsappUpdate;
    _accountType = p.accountType;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(UpdateProfileEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _mobileController.text.trim(),
          accountType: _accountType,
          companyName:
              _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
          gstinNo: _gstController.text.trim().isNotEmpty ? _gstController.text.trim() : null,
          getWhatsappUpdate: _getWhatsappUpdate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateFields(state);
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError && state is! ProfileUpdating) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(const LoadProfileEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final isSubmitting = state is ProfileUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account type selector
                  const Text('Account Type'),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Individual', label: Text('Individual')),
                      ButtonSegment(value: 'Corporate', label: Text('Corporate')),
                    ],
                    selected: {_accountType},
                    onSelectionChanged: (value) =>
                        setState(() => _accountType = value.first),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
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
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
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
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+91 ',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Mobile is required';
                      if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Corporate fields
                  if (_accountType == 'Corporate') ...[
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gstController,
                      decoration: const InputDecoration(
                        labelText: 'GSTIN Number',
                        prefixIcon: Icon(Icons.receipt_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // WhatsApp toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('WhatsApp Updates'),
                    subtitle:
                        const Text('Receive order & offer updates on WhatsApp'),
                    value: _getWhatsappUpdate,
                    onChanged: (v) => setState(() => _getWhatsappUpdate = v),
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: isSubmitting ? null : _submit,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
