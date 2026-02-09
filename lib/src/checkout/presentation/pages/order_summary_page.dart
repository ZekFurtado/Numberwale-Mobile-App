import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/cart_summary_card.dart';
import 'package:numberwale/core/widgets/product_list_item.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({
    super.key,
    required this.deliveryAddress,
  });

  final Map<String, dynamic> deliveryAddress;

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  String _selectedPaymentMethod = 'razorpay';

  // Mock cart items - will be replaced with BLoC
  final List<Map<String, dynamic>> _cartItems = [
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
    for (var item in _cartItems) {
      final price = item['price'] as double;
      final discount = item['discount'] as double?;
      final discountedPrice = discount != null ? price * (1 - discount / 100) : price;
      subtotal += discountedPrice;
    }
    return subtotal;
  }

  void _proceedToPayment() {
    // Mock payment - in real app, integrate Razorpay/PhonePe
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Processing Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Please wait while we process your payment via ${_selectedPaymentMethod == 'razorpay' ? 'Razorpay' : 'PhonePe'}...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close processing dialog

      // Navigate to success page
      Navigator.pushReplacementNamed(
        context,
        Routes.orderSuccess,
        arguments: {
          'orderId': 'ORD${DateTime.now().millisecondsSinceEpoch}',
          'amount': _calculateSubtotal() * 1.18,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = _calculateSubtotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Delivery Address Section
                Text(
                  'Delivery Address',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AddressCard(
                  addressLine1: widget.deliveryAddress['addressLine1'],
                  addressLine2: widget.deliveryAddress['addressLine2'],
                  landmark: widget.deliveryAddress['landmark'],
                  city: widget.deliveryAddress['city'],
                  state: widget.deliveryAddress['state'],
                  pinCode: widget.deliveryAddress['pinCode'],
                  isPrimary: widget.deliveryAddress['isPrimary'] ?? false,
                  showActions: false,
                  onTap: () {
                    Navigator.pop(context); // Go back to change address
                  },
                ),

                const SizedBox(height: 24),

                // Order Items Section
                Text(
                  'Order Items (${_cartItems.length})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ..._cartItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ProductListItem(
                      phoneNumber: item['phoneNumber'],
                      price: item['price'],
                      category: item['category'],
                      features: List<String>.from(item['features']),
                      discount: item['discount'],
                      isFeatured: false,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.productDetail,
                          arguments: item['phoneNumber'],
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Payment Method Section
                Text(
                  'Payment Method',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'razorpay',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                        title: const Text('Razorpay'),
                        subtitle: const Text('Card, UPI, Net Banking, Wallet'),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.payment,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        value: 'phonepe',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() => _selectedPaymentMethod = value!);
                        },
                        title: const Text('PhonePe'),
                        subtitle: const Text('UPI & Wallet'),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Price Summary
                CartSummaryCard(subtotal: subtotal),
              ],
            ),
          ),

          // Bottom action button
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
              child: FilledButton.icon(
                onPressed: _proceedToPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Proceed to Payment'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
