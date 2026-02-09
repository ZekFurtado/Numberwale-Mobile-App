import 'package:flutter/material.dart';
import 'package:numberwale/core/widgets/text_input_field.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({
    super.key,
    this.addressId,
    this.initialData,
  });

  final String? addressId; // null for new address, non-null for edit
  final Map<String, dynamic>? initialData;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  bool _isPrimary = false;
  bool _isLoadingPincode = false;

  bool get _isEditMode => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _addressLine1Controller.text = data['addressLine1'] ?? '';
      _addressLine2Controller.text = data['addressLine2'] ?? '';
      _landmarkController.text = data['landmark'] ?? '';
      _pinCodeController.text = data['pinCode'] ?? '';
      _cityController.text = data['city'] ?? '';
      _stateController.text = data['state'] ?? '';
      _isPrimary = data['isPrimary'] ?? false;
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _landmarkController.dispose();
    _pinCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _onPinCodeChanged(String? pincode) async {
    if (pincode?.length == 6) {
      setState(() => _isLoadingPincode = true);

      // Mock API call - replace with actual pincode API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      if (mounted) {
        setState(() {
          _cityController.text = 'Mumbai';
          _stateController.text = 'Maharashtra';
          _isLoadingPincode = false;
        });
      }
    }
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final addressData = {
        'id': widget.addressId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'addressLine1': _addressLine1Controller.text,
        'addressLine2': _addressLine2Controller.text,
        'landmark': _landmarkController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pinCode': _pinCodeController.text,
        'isPrimary': _isPrimary,
      };

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Address updated successfully' : 'Address added successfully',
          ),
        ),
      );

      // Return to previous screen with address data
      Navigator.pop(context, addressData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Address' : 'Add New Address'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Address Line 1
            TextInputField(
              controller: _addressLine1Controller,
              label: 'Address Line 1',
              hintText: 'House No., Building Name',
              icon: Icon(Icons.home),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address line 1';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Address Line 2
            TextInputField(
              controller: _addressLine2Controller,
              label: 'Address Line 2 (Optional)',
              hintText: 'Road Name, Area, Colony',
              icon: Icon(Icons.location_on),
            ),

            const SizedBox(height: 16),

            // Landmark
            TextInputField(
              controller: _landmarkController,
              label: 'Landmark (Optional)',
              hintText: 'Near famous place',
              icon: Icon(Icons.place),
            ),

            const SizedBox(height: 16),

            // PIN Code
            TextInputField(
              controller: _pinCodeController,
              label: 'PIN Code',
              hintText: '6-digit PIN code',
              icon: Icon(Icons.pin_drop),
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: _onPinCodeChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter PIN code';
                }
                if (value.length != 6) {
                  return 'PIN code must be 6 digits';
                }
                return null;
              },
            ),

            if (_isLoadingPincode) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Fetching city and state...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // City (auto-filled)
            TextInputField(
              controller: _cityController,
              label: 'City',
              hintText: 'Auto-filled from PIN code',
              icon: Icon(Icons.location_city),
              enabled: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // State (auto-filled)
            TextInputField(
              controller: _stateController,
              label: 'State',
              hintText: 'Auto-filled from PIN code',
              icon: Icon(Icons.map),
              enabled: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'State is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Mark as Primary checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                value: _isPrimary,
                onChanged: (value) {
                  setState(() => _isPrimary = value ?? false);
                },
                title: const Text('Mark as Primary Address'),
                subtitle: const Text('Use this address by default'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _saveAddress,
              icon: const Icon(Icons.save),
              label: Text(_isEditMode ? 'Update Address' : 'Save Address'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
