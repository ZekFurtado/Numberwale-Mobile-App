import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/presentation/bloc/address_bloc.dart';

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const GetAddressesEvent());
  }

  Future<void> _addNewAddress() async {
    await Navigator.pushNamed(context, Routes.addressForm);
    if (mounted) {
      context.read<AddressBloc>().add(const GetAddressesEvent());
    }
  }

  Future<void> _editAddress(Address address) async {
    await Navigator.pushNamed(
      context,
      Routes.addressForm,
      arguments: {
        'addressId': address.id,
        'address': address,
      },
    );
    if (mounted) {
      context.read<AddressBloc>().add(const GetAddressesEvent());
    }
  }

  void _deleteAddress(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (address.id != null) {
                context.read<AddressBloc>().add(
                      DeleteAddressEvent(addressId: address.id!),
                    );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _continueToSummary(List<Address> addresses) {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }

    final selected = addresses.firstWhere(
      (a) => a.id == _selectedAddressId,
    );

    Navigator.pushNamed(
      context,
      Routes.orderSummary,
      arguments: {
        'id': selected.id ?? '',
        'addressLine1': selected.addressLine1,
        'addressLine2': selected.addressLine2,
        'landmark': selected.landmark,
        'city': selected.city,
        'state': selected.state,
        'pinCode': selected.pinCode,
        'isPrimary': selected.isPrimary,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Address'),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is AddressesLoaded) {
            // Auto-select primary address on first load
            if (_selectedAddressId == null && state.addresses.isNotEmpty) {
              final addresses = state.addresses;
              final primary = addresses.any((a) => a.isPrimary)
                  ? addresses.firstWhere((a) => a.isPrimary)
                  : addresses.first;
              setState(() => _selectedAddressId = primary.id);
            }
          } else if (state is AddressDeleted) {
            if (_selectedAddressId == state.addressId) {
              setState(() => _selectedAddressId = null);
            }
            context.read<AddressBloc>().add(const GetAddressesEvent());
          }
        },
        builder: (context, state) {
          if (state is LoadingAddresses) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses =
              state is AddressesLoaded ? state.addresses : <Address>[];

          if (addresses.isEmpty) {
            return EmptyState(
              icon: Icons.location_off,
              title: 'No Addresses Found',
              message: 'Add a delivery address to continue with your order',
              actionLabel: 'Add Address',
              onAction: _addNewAddress,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AddressCard(
                        addressLine1: address.addressLine1,
                        addressLine2: address.addressLine2,
                        landmark: address.landmark,
                        city: address.city,
                        state: address.state,
                        pinCode: address.pinCode,
                        isPrimary: address.isPrimary,
                        isSelected: address.id == _selectedAddressId,
                        onTap: () =>
                            setState(() => _selectedAddressId = address.id),
                        onEdit: () => _editAddress(address),
                        onDelete: () => _deleteAddress(context, address),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _addNewAddress,
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Address'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _continueToSummary(addresses),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continue to Order Summary'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
