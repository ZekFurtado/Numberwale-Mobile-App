import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart';
import 'package:numberwale/core/widgets/text_input_field.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/presentation/bloc/address_bloc.dart';

class AddressFormPage extends StatelessWidget {
  const AddressFormPage({
    super.key,
    this.addressId,
    this.address,
  });

  final String? addressId; // null for new address, non-null for edit
  final Address? address;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddressBloc>(),
      child: _AddressFormView(
        addressId: addressId,
        address: address,
      ),
    );
  }
}

class _AddressFormView extends StatefulWidget {
  const _AddressFormView({
    this.addressId,
    this.address,
  });

  final String? addressId;
  final Address? address;

  @override
  State<_AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<_AddressFormView> {
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
    if (widget.address != null) {
      final address = widget.address!;
      _addressLine1Controller.text = address.addressLine1;
      _addressLine2Controller.text = address.addressLine2 ?? '';
      _landmarkController.text = address.landmark ?? '';
      _pinCodeController.text = address.pinCode;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _isPrimary = address.isPrimary;
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
      // Trigger PIN code lookup via BLoC
      context.read<AddressBloc>().add(
            GetLocationFromPinCodeEvent(pinCode: pincode!),
          );
    }
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode && widget.addressId != null) {
        // Update existing address
        context.read<AddressBloc>().add(
              UpdateAddressEvent(
                addressId: widget.addressId!,
                addressLine1: _addressLine1Controller.text,
                addressLine2: _addressLine2Controller.text.isEmpty
                    ? null
                    : _addressLine2Controller.text,
                landmark: _landmarkController.text.isEmpty
                    ? null
                    : _landmarkController.text,
                city: _cityController.text,
                state: _stateController.text,
                pinCode: _pinCodeController.text,
                isPrimary: _isPrimary,
              ),
            );
      } else {
        // Add new address
        context.read<AddressBloc>().add(
              AddAddressEvent(
                addressLine1: _addressLine1Controller.text,
                addressLine2: _addressLine2Controller.text.isEmpty
                    ? null
                    : _addressLine2Controller.text,
                landmark: _landmarkController.text.isEmpty
                    ? null
                    : _landmarkController.text,
                city: _cityController.text,
                state: _stateController.text,
                pinCode: _pinCodeController.text,
                isPrimary: _isPrimary,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Address' : 'Add New Address'),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is LoadingLocation) {
            setState(() => _isLoadingPincode = true);
          } else if (state is LocationLoaded) {
            setState(() {
              _cityController.text = state.locationInfo.city;
              _stateController.text = state.locationInfo.state;
              _isLoadingPincode = false;
            });
          } else if (state is AddressAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address added successfully'),
              ),
            );
            Navigator.pop(context, state.address);
          } else if (state is AddressUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address updated successfully'),
              ),
            );
            Navigator.pop(context, state.address);
          } else if (state is AddressError) {
            // Handle PIN code lookup error
            if (_isLoadingPincode) {
              setState(() => _isLoadingPincode = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddingAddress || state is UpdatingAddress;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Address Line 1
                TextInputField(
                  controller: _addressLine1Controller,
                  label: 'Address Line 1',
                  hintText: 'House No., Building Name',
                  icon: const Icon(Icons.home),
                  enabled: !isLoading,
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
                  icon: const Icon(Icons.location_on),
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

                // Landmark
                TextInputField(
                  controller: _landmarkController,
                  label: 'Landmark (Optional)',
                  hintText: 'Near famous place',
                  icon: const Icon(Icons.place),
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

                // PIN Code
                TextInputField(
                  controller: _pinCodeController,
                  label: 'PIN Code',
                  hintText: '6-digit PIN code',
                  icon: const Icon(Icons.pin_drop),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: _onPinCodeChanged,
                  enabled: !isLoading,
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
                  icon: const Icon(Icons.location_city),
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
                  icon: const Icon(Icons.map),
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
                    onChanged: isLoading
                        ? null
                        : (value) {
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
                  onPressed: isLoading ? null : _saveAddress,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isLoading
                        ? (_isEditMode ? 'Updating...' : 'Saving...')
                        : (_isEditMode ? 'Update Address' : 'Save Address'),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
