import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/cart_item_card.dart';
import 'package:numberwale/core/widgets/cart_summary_card.dart';
import 'package:numberwale/core/widgets/empty_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Mock cart data - will be replaced with BLoC
  List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'phoneNumber': '9876543210',
      'price': 25000.0,
      'operator': 'Airtel',
      'category': 'VIP',
      'discount': 10.0,
    },
    {
      'id': '2',
      'phoneNumber': '9999999999',
      'price': 50000.0,
      'operator': 'Jio',
      'category': 'Premium VIP',
      'discount': null,
    },
    {
      'id': '3',
      'phoneNumber': '9898989898',
      'price': 28000.0,
      'operator': 'Vi',
      'category': 'Mirror',
      'discount': 8.0,
    },
  ];

  void _removeItem(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cartItems.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in _cartItems) {
      final price = item['price'] as double;
      final discount = item['discount'] as double?;
      final discountedPrice = discount != null ? price * (1 - discount / 100) : price;
      subtotal += discountedPrice;
    }
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = _cartItems.isEmpty;
    final subtotal = _calculateSubtotal();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart${isEmpty ? '' : ' (${_cartItems.length})'}'),
        actions: [
          if (!isEmpty)
            IconButton(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your Cart is Empty',
              message: 'Add some premium numbers to your cart to get started!',
              actionLabel: 'Explore Numbers',
              onAction: () {
                Navigator.pop(context);
              },
            )
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return CartItemCard(
                        phoneNumber: item['phoneNumber'],
                        price: item['price'],
                        operator: item['operator'],
                        category: item['category'],
                        discount: item['discount'],
                        onRemove: () => _removeItem(item['id']),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.productDetail,
                            arguments: item['phoneNumber'],
                          );
                        },
                      );
                    },
                  ),
                ),

                // Price summary (sticky bottom)
                Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CartSummaryCard(
                            subtotal: subtotal,
                            discount: 0,
                          ),

                          const SizedBox(height: 16),

                          // Checkout button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, Routes.checkout);
                              },
                              icon: const Icon(Icons.shopping_bag),
                              label: const Text('Proceed to Checkout'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
