import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/cart_summary_card.dart';
import 'package:numberwale/core/widgets/product_list_item.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';

class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({
    super.key,
    required this.deliveryAddress,
  });

  final Map<String, dynamic> deliveryAddress;

  // TODO: Replace with real cart data from CartBloc
  List<Map<String, dynamic>> get _cartItems => [
        {
          'phoneNumber': '9876543210',
          'price': 25000.0,
          'operator': 'Airtel',
          'category': 'VIP',
          'discount': 10.0,
          'features': ['Sequential', 'Premium'],
        },
        {
          'phoneNumber': '9999999999',
          'price': 50000.0,
          'operator': 'Jio',
          'category': 'Premium VIP',
          'discount': null,
          'features': ['All 9s', 'Unique'],
        },
      ];

  double _calculateSubtotal() {
    double subtotal = 0;
    for (final item in _cartItems) {
      final price = item['price'] as double;
      final discount = item['discount'] as double?;
      subtotal += discount != null ? price * (1 - discount / 100) : price;
    }
    return subtotal;
  }

  void _proceedToPayment(BuildContext context) {
    final addressId = deliveryAddress['id'] as String? ?? '';
    context.read<CartBloc>().add(CheckoutEvent(addressId: addressId));
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _onCartStateChange(BuildContext context, CartState state) {
    if (state is CheckoutComplete) {
      Navigator.pushReplacementNamed(
        context,
        Routes.orderSuccess,
        arguments: {
          'orderId': state.result.orderId,
          'orderNumber': state.result.orderNumber,
          'amount': state.result.amount,
        },
      );
    } else if (state is CartError) {
      _showError(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = _calculateSubtotal();

    return BlocListener<CartBloc, CartState>(
      listener: _onCartStateChange,
      child: Scaffold(
        appBar: AppBar(title: const Text('Order Summary')),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final isLoading = state is CheckingOut;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Delivery Address',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      AddressCard(
                        addressLine1: deliveryAddress['addressLine1'],
                        addressLine2: deliveryAddress['addressLine2'],
                        landmark: deliveryAddress['landmark'],
                        city: deliveryAddress['city'],
                        state: deliveryAddress['state'],
                        pinCode: deliveryAddress['pinCode'],
                        isPrimary: deliveryAddress['isPrimary'] ?? false,
                        showActions: false,
                        onTap: () => Navigator.pop(context),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Order Items (${_cartItems.length})',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._cartItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ProductListItem(
                              phoneNumber: item['phoneNumber'],
                              price: item['price'],
                              category: item['category'],
                              features: List<String>.from(item['features']),
                              discount: item['discount'],
                              isFeatured: false,
                              onTap: () => Navigator.pushNamed(
                                context,
                                Routes.productDetail,
                                arguments: item['phoneNumber'],
                              ),
                            ),
                          )),

                      const SizedBox(height: 24),

                      CartSummaryCard(subtotal: subtotal),
                    ],
                  ),
                ),

                _BottomBar(
                  isLoading: isLoading,
                  onTap: () => _proceedToPayment(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
        child: FilledButton.icon(
          onPressed: isLoading ? null : onTap,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.payment),
          label: Text(isLoading ? 'Processing...' : 'Proceed to Payment'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ),
    );
  }
}
