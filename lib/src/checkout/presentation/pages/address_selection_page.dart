import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/empty_state.dart';

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  // Mock addresses - will be replaced with BLoC
  List<Map<String, dynamic>> _addresses = [
    {
      'id': '1',
      'addressLine1': '123, Ravi Apartment',
      'addressLine2': 'MG Road, Andheri West',
      'landmark': 'Near Metro Station',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'pinCode': '400053',
      'isPrimary': true,
    },
    {
      'id': '2',
      'addressLine1': '456, Shanti Complex',
      'addressLine2': 'Link Road, Malad West',
      'landmark': 'Opposite City Mall',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'pinCode': '400064',
      'isPrimary': false,
    },
  ];

  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Auto-select primary address
    final primaryAddress = _addresses.firstWhere(
      (addr) => addr['isPrimary'] == true,
      orElse: () => _addresses.isNotEmpty ? _addresses.first : {},
    );
    if (primaryAddress.isNotEmpty) {
      _selectedAddressId = primaryAddress['id'];
    }
  }

  Future<void> _addNewAddress() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.addressForm,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _addresses.add(result);
      });
    }
  }

  Future<void> _editAddress(Map<String, dynamic> address) async {
    final result = await Navigator.pushNamed(
      context,
      Routes.addressForm,
      arguments: {
        'addressId': address['id'],
        'initialData': address,
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final index = _addresses.indexWhere((addr) => addr['id'] == address['id']);
        if (index != -1) {
          _addresses[index] = result;
        }
      });
    }
  }

  void _deleteAddress(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _addresses.removeWhere((addr) => addr['id'] == addressId);
                if (_selectedAddressId == addressId) {
                  _selectedAddressId = _addresses.isNotEmpty ? _addresses.first['id'] : null;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _continueToSummary() {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }

    final selectedAddress = _addresses.firstWhere(
      (addr) => addr['id'] == _selectedAddressId,
    );

    Navigator.pushNamed(
      context,
      Routes.orderSummary,
      arguments: selectedAddress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = _addresses.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Address'),
      ),
      body: isEmpty
          ? EmptyState(
              icon: Icons.location_off,
              title: 'No Addresses Found',
              message: 'Add a delivery address to continue with your order',
              actionLabel: 'Add Address',
              onAction: _addNewAddress,
            )
          : Column(
              children: [
                // Addresses list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AddressCard(
                          addressLine1: address['addressLine1'],
                          addressLine2: address['addressLine2'],
                          landmark: address['landmark'],
                          city: address['city'],
                          state: address['state'],
                          pinCode: address['pinCode'],
                          isPrimary: address['isPrimary'] ?? false,
                          isSelected: address['id'] == _selectedAddressId,
                          onTap: () {
                            setState(() {
                              _selectedAddressId = address['id'];
                            });
                          },
                          onEdit: () => _editAddress(address),
                          onDelete: () => _deleteAddress(address['id']),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom actions
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
                        // Add new address button
                        OutlinedButton.icon(
                          onPressed: _addNewAddress,
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Address'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Continue button
                        FilledButton.icon(
                          onPressed: _continueToSummary,
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
            ),
    );
  }
}
