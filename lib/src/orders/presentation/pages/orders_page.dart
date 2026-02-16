import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/order_card.dart';
import 'package:numberwale/src/orders/domain/entities/order.dart';
import 'package:numberwale/src/orders/presentation/bloc/order_bloc.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderBloc>()..add(const LoadOrdersEvent()),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  String _selectedFilter = 'all';

  /// Maps an [Order]'s string status to the [OrderStatus] enum used by [OrderCard].
  OrderStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  /// Returns the display label for the filter chips.
  String _filterLabel(String filter) {
    if (filter == 'all') return 'No Orders Yet';
    final capitalized =
        filter.substring(0, 1).toUpperCase() + filter.substring(1);
    return 'No $capitalized Orders';
  }

  /// Filters the order list by the currently selected status chip.
  List<Order> _filterOrders(List<Order> orders) {
    if (_selectedFilter == 'all') return orders;
    return orders.where((order) {
      return order.status.toLowerCase() == _selectedFilter;
    }).toList();
  }

  /// Computes a total amount for an order from its products.
  double _orderTotal(Order order) {
    if (order.payment != null) return order.payment!.amount;
    return order.products.fold(0.0, (sum, p) => sum + p.finalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context
                        .read<OrderBloc>()
                        .add(const LoadOrdersEvent()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Resolve the orders list from either loaded or loading-more state
          final List<Order> allOrders;
          final bool hasNextPage;
          final bool isLoadingMore;

          if (state is OrdersLoaded) {
            allOrders = state.orders;
            hasNextPage = state.hasNextPage;
            isLoadingMore = false;
          } else if (state is OrderLoadingMore) {
            allOrders = state.currentOrders;
            hasNextPage = false;
            isLoadingMore = true;
          } else {
            allOrders = const [];
            hasNextPage = false;
            isLoadingMore = false;
          }

          final filteredOrders = _filterOrders(allOrders);
          final isEmpty = filteredOrders.isEmpty;

          return Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      value: 'all',
                      isSelected: _selectedFilter == 'all',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'all'),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pending',
                      value: 'pending',
                      isSelected: _selectedFilter == 'pending',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'pending'),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Confirmed',
                      value: 'confirmed',
                      isSelected: _selectedFilter == 'confirmed',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'confirmed'),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Processing',
                      value: 'processing',
                      isSelected: _selectedFilter == 'processing',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'processing'),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Delivered',
                      value: 'delivered',
                      isSelected: _selectedFilter == 'delivered',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'delivered'),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Cancelled',
                      value: 'cancelled',
                      isSelected: _selectedFilter == 'cancelled',
                      onSelected: () =>
                          setState(() => _selectedFilter = 'cancelled'),
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
                        title: _filterLabel(_selectedFilter),
                        message: _selectedFilter == 'all'
                            ? 'Start shopping for premium numbers to see your orders here'
                            : 'You don\'t have any $_selectedFilter orders',
                        actionLabel: _selectedFilter == 'all'
                            ? 'Explore Numbers'
                            : 'View All Orders',
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
                          context
                              .read<OrderBloc>()
                              .add(const LoadOrdersEvent());
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          // +1 for the "Load More" / spinner row at the bottom
                          itemCount: filteredOrders.length +
                              (hasNextPage || isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Load More / loading indicator row
                            if (index == filteredOrders.length) {
                              if (isLoadingMore) {
                                return const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              // hasNextPage is true
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                                child: Center(
                                  child: OutlinedButton(
                                    onPressed: () => context
                                        .read<OrderBloc>()
                                        .add(
                                            const LoadMoreOrdersEvent()),
                                    child: const Text('Load More'),
                                  ),
                                ),
                              );
                            }

                            final order = filteredOrders[index];
                            return OrderCard(
                              orderId: order.orderNumber,
                              date: order.createdAt ?? DateTime.now(),
                              totalAmount: _orderTotal(order),
                              itemCount: order.products.length,
                              status: _mapStatus(order.status),
                              phoneNumbers: order.products
                                  .map((p) => p.productMobileNumber)
                                  .toList(),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.orderDetail,
                                  arguments: order.id ?? order.orderNumber,
                                );
                              },
                            );
                          },
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
