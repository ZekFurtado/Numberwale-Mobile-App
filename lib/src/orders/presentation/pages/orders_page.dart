import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedFilter = 'all';

  // Mock orders data - will be replaced with BLoC
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': 'ORD1234567890',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'totalAmount': 73125.0, // Including GST
      'itemCount': 2,
      'status': OrderStatus.delivered,
      'phoneNumbers': ['9876543210', '9999999999'],
    },
    {
      'id': 'ORD1234567891',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'totalAmount': 35400.0,
      'itemCount': 1,
      'status': OrderStatus.processing,
      'phoneNumbers': ['9898989898'],
    },
    {
      'id': 'ORD1234567892',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'totalAmount': 17700.0,
      'itemCount': 1,
      'status': OrderStatus.confirmed,
      'phoneNumbers': ['9876000000'],
    },
    {
      'id': 'ORD1234567893',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'totalAmount': 41300.0,
      'itemCount': 1,
      'status': OrderStatus.delivered,
      'phoneNumbers': ['9811111111'],
    },
    {
      'id': 'ORD1234567894',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'totalAmount': 14160.0,
      'itemCount': 1,
      'status': OrderStatus.cancelled,
      'phoneNumbers': ['9123456789'],
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'all') {
      return _allOrders;
    }

    final filterStatus = OrderStatus.values.firstWhere(
      (status) => status.label.toLowerCase() == _selectedFilter,
    );

    return _allOrders.where((order) {
      return order['status'] == filterStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredOrders = _filteredOrders;
    final isEmpty = filteredOrders.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  value: 'all',
                  isSelected: _selectedFilter == 'all',
                  onSelected: () {
                    setState(() => _selectedFilter = 'all');
                  },
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  value: 'pending',
                  isSelected: _selectedFilter == 'pending',
                  onSelected: () {
                    setState(() => _selectedFilter = 'pending');
                  },
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Confirmed',
                  value: 'confirmed',
                  isSelected: _selectedFilter == 'confirmed',
                  onSelected: () {
                    setState(() => _selectedFilter = 'confirmed');
                  },
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Processing',
                  value: 'processing',
                  isSelected: _selectedFilter == 'processing',
                  onSelected: () {
                    setState(() => _selectedFilter = 'processing');
                  },
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Delivered',
                  value: 'delivered',
                  isSelected: _selectedFilter == 'delivered',
                  onSelected: () {
                    setState(() => _selectedFilter == 'delivered');
                  },
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cancelled',
                  value: 'cancelled',
                  isSelected: _selectedFilter == 'cancelled',
                  onSelected: () {
                    setState(() => _selectedFilter = 'cancelled');
                  },
                  theme: theme,
                ),
              ],
            ),
          ),

          // Orders list or empty state
          Expanded(
            child: isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long,
                    title: _selectedFilter == 'all'
                        ? 'No Orders Yet'
                        : 'No ${_selectedFilter.substring(0, 1).toUpperCase()}${_selectedFilter.substring(1)} Orders',
                    message: _selectedFilter == 'all'
                        ? 'Start shopping for premium numbers to see your orders here'
                        : 'You don\'t have any ${_selectedFilter} orders',
                    actionLabel: _selectedFilter == 'all' ? 'Explore Numbers' : 'View All Orders',
                    onAction: () {
                      if (_selectedFilter == 'all') {
                        Navigator.pop(context);
                      } else {
                        setState(() => _selectedFilter = 'all');
                      }
                    },
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      // Refresh orders - will be implemented with BLoC
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderCard(
                          orderId: order['id'],
                          date: order['date'],
                          totalAmount: order['totalAmount'],
                          itemCount: order['itemCount'],
                          status: order['status'],
                          phoneNumbers: List<String>.from(order['phoneNumbers']),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.orderDetail,
                              arguments: order['id'],
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onSelected,
    required this.theme,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onSelected;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }
}
