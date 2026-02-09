import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/cart_summary_card.dart';
import 'package:numberwale/core/widgets/order_card.dart';
import 'package:numberwale/core/widgets/product_list_item.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({
    super.key,
    required this.orderId,
  });

  final String orderId;

  // Mock order details - will be replaced with BLoC
  Map<String, dynamic> _getOrderDetails() {
    return {
      'id': orderId,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': OrderStatus.delivered,
      'items': [
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
      ],
      'deliveryAddress': {
        'addressLine1': '123, Ravi Apartment',
        'addressLine2': 'MG Road, Andheri West',
        'landmark': 'Near Metro Station',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pinCode': '400053',
        'isPrimary': true,
      },
      'paymentMethod': 'Razorpay',
      'subtotal': 72500.0,
      'discount': 0.0,
    };
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = _getOrderDetails();
    final items = List<Map<String, dynamic>>.from(order['items']);
    final deliveryAddress = order['deliveryAddress'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Order Status Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['id'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (order['status'] as OrderStatus).color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (order['status'] as OrderStatus).color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (order['status'] as OrderStatus).icon,
                              size: 16,
                              color: (order['status'] as OrderStatus).color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (order['status'] as OrderStatus).label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: (order['status'] as OrderStatus).color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(order['date']),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Order Items Section
          Text(
            'Order Items (${items.length})',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...items.map((item) {
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

          const SizedBox(height: 20),

          // Delivery Address Section
          Text(
            'Delivery Address',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
          ),

          const SizedBox(height: 20),

          // Payment Info Section
          Text(
            'Payment Information',
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['paymentMethod'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Paid Online',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Price Summary
          CartSummaryCard(
            subtotal: order['subtotal'],
            discount: order['discount'],
          ),

          const SizedBox(height: 20),

          // Need Help Section
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.contactUs);
                    },
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Support'),
                    style: OutlinedButton.styleFrom(
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
