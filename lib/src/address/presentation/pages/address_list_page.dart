import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/presentation/bloc/address_bloc.dart';

/// Standalone address management page that users can access from their profile
class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddressBloc>()..add(const GetAddressesEvent()),
      child: const _AddressListView(),
    );
  }
}

class _AddressListView extends StatelessWidget {
  const _AddressListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewAddress(context),
            tooltip: 'Add New Address',
          ),
        ],
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
          } else if (state is AddressDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address deleted successfully')),
            );
            // Refresh the list
            context.read<AddressBloc>().add(const GetAddressesEvent());
          } else if (state is PrimaryAddressSet) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Primary address updated successfully'),
              ),
            );
            // Refresh the list
            context.read<AddressBloc>().add(const GetAddressesEvent());
          }
        },
        builder: (context, state) {
          if (state is LoadingAddresses) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddressesLoaded) {
            final addresses = state.addresses;

            if (addresses.isEmpty) {
              return EmptyState(
                icon: Icons.location_off,
                title: 'No Addresses Found',
                message: 'Add a delivery address to get started',
                actionLabel: 'Add Address',
                onAction: () => _addNewAddress(context),
              );
            }

            return ListView.builder(
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
                    onEdit: () => _editAddress(context, address),
                    onDelete: () => _deleteAddress(context, address),
                  ),
                );
              },
            );
          }

          // Initial or error state
          return EmptyState(
            icon: Icons.location_off,
            title: 'No Addresses Found',
            message: 'Add a delivery address to get started',
            actionLabel: 'Add Address',
            onAction: () => _addNewAddress(context),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewAddress(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  Future<void> _addNewAddress(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      Routes.addressForm,
    );

    if (result != null && context.mounted) {
      // Refresh the list after adding
      context.read<AddressBloc>().add(const GetAddressesEvent());
    }
  }

  Future<void> _editAddress(BuildContext context, Address address) async {
    final result = await Navigator.pushNamed(
      context,
      Routes.addressForm,
      arguments: {
        'addressId': address.id,
        'address': address,
      },
    );

    if (result != null && context.mounted) {
      // Refresh the list after editing
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
}
