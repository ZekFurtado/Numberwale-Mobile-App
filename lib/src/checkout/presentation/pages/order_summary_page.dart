import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:numberwale/core/services/injection_container.dart';
import 'package:numberwale/core/services/phonepe_service.dart';
import 'package:numberwale/core/services/razorpay_service.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/cart_summary_card.dart';
import 'package:numberwale/core/widgets/product_list_item.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';

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
  String _selectedPaymentMethod = 'phonepe';
  late final RazorpayService _razorpayService;

  // TODO: Replace with real cart data from CartBloc
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

  @override
  void initState() {
    super.initState();
    _razorpayService = sl<RazorpayService>();
    _razorpayService.initialize(
      onSuccess: _handleRazorpaySuccess,
      onFailure: _handleRazorpayFailure,
      onExternalWallet: _handleRazorpayExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  double _calculateSubtotal() {
    double subtotal = 0;
    for (final item in _cartItems) {
      final price = item['price'] as double;
      final discount = item['discount'] as double?;
      subtotal +=
          discount != null ? price * (1 - discount / 100) : price;
    }
    return subtotal;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _navigateToSuccess(String orderId) {
    Navigator.pushReplacementNamed(
      context,
      Routes.orderSuccess,
      arguments: {
        'orderId': orderId,
        'amount': _calculateSubtotal() * 1.18,
      },
    );
  }

  // ─── Checkout trigger ────────────────────────────────────────────────────

  void _proceedToPayment() {
    final addressId = widget.deliveryAddress['id'] as String? ?? '';
    context.read<CartBloc>().add(
          CheckoutEvent(
            addressId: addressId,
            paymentGateway: _selectedPaymentMethod,
          ),
        );
  }

  // ─── Razorpay callbacks ──────────────────────────────────────────────────

  void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    log('Razorpay success: paymentId=${response.paymentId}, '
        'orderId=${response.orderId}, signature=${response.signature}');
    context.read<CartBloc>().add(
          ConfirmPaymentEvent(
            paymentId: response.paymentId ?? '',
            orderId: response.orderId ?? '',
            gateway: 'razorpay',
            signature: response.signature,
          ),
        );
  }

  void _handleRazorpayFailure(PaymentFailureResponse response) {
    log('Razorpay failure: code=${response.code}, message=${response.message}');
    _showError('Payment failed: ${response.message ?? 'Please try again.'}');
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    log('Razorpay external wallet: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Redirecting to ${response.walletName}...'),
      ),
    );
  }

  // ─── PhonePe flow ────────────────────────────────────────────────────────

  Future<void> _launchPhonePe(CheckoutResult result) async {
    if (result.phonePeBody == null || result.phonePeChecksum == null) {
      _showError('PhonePe payment data is missing. Please contact support.');
      return;
    }
    try {
      final phonePeService = PhonePeService();
      final response = await phonePeService.startPayment(
        body: result.phonePeBody!,
        checksum: result.phonePeChecksum!,
      );

      if (response == null) {
        _showError('PhonePe returned no response. Please try again.');
        return;
      }

      final status = response['status'] as String? ?? '';
      log('PhonePe status: $status');

      if (status == 'SUCCESS') {
        final transactionId =
            response['transactionId'] as String? ?? result.orderId;
        if (mounted) {
          context.read<CartBloc>().add(
                VerifyPhonePePaymentEvent(
                  transactionId: transactionId,
                  orderId: result.orderId,
                ),
              );
        }
      } else {
        _showError(
            'Payment failed: ${response['error'] ?? status}. Please try again.');
      }
    } catch (e) {
      log('PhonePe error: $e');
      _showError('Payment could not be completed. Please try again.');
    }
  }

  // ─── Razorpay flow ───────────────────────────────────────────────────────

  void _launchRazorpay(CheckoutResult result) {
    _razorpayService.openCheckout(
      orderId: result.orderId,
      amount: result.amount.toInt(), // already in paise from backend
      currency: result.currency,
      contact: widget.deliveryAddress['phone'] as String? ?? '',
      email: widget.deliveryAddress['email'] as String? ?? '',
    );
  }

  // ─── BLoC state listener ─────────────────────────────────────────────────

  void _onCartStateChange(BuildContext context, CartState state) {
    if (state is CheckoutInitiated) {
      if (state.result.gateway == 'phonepe') {
        _launchPhonePe(state.result);
      } else if (state.result.gateway == 'razorpay') {
        _launchRazorpay(state.result);
      }
    } else if (state is PaymentConfirmed || state is PhonePePaymentVerified) {
      _navigateToSuccess('');
    } else if (state is CartError) {
      _showError(state.message);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

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
            final isLoading = state is CheckingOut ||
                state is VerifyingPhonePePayment ||
                state is ConfirmingPayment;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Delivery Address ──────────────────────────
                      Text(
                        'Delivery Address',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      AddressCard(
                        addressLine1:
                            widget.deliveryAddress['addressLine1'],
                        addressLine2:
                            widget.deliveryAddress['addressLine2'],
                        landmark: widget.deliveryAddress['landmark'],
                        city: widget.deliveryAddress['city'],
                        state: widget.deliveryAddress['state'],
                        pinCode: widget.deliveryAddress['pinCode'],
                        isPrimary:
                            widget.deliveryAddress['isPrimary'] ?? false,
                        showActions: false,
                        onTap: () => Navigator.pop(context),
                      ),

                      const SizedBox(height: 24),

                      // ── Order Items ───────────────────────────────
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
                              features:
                                  List<String>.from(item['features']),
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

                      // ── Payment Method ────────────────────────────
                      Text(
                        'Payment Method',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _PaymentMethodCard(
                        selected: _selectedPaymentMethod,
                        enabled: !isLoading,
                        onChanged: (value) =>
                            setState(() => _selectedPaymentMethod = value),
                      ),

                      const SizedBox(height: 24),

                      // ── Price Summary ─────────────────────────────
                      CartSummaryCard(subtotal: subtotal),
                    ],
                  ),
                ),

                // ── Bottom CTA ────────────────────────────────────
                _BottomBar(
                  isLoading: isLoading,
                  onTap: _proceedToPayment,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final String selected;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _PaymentOption(
            value: 'phonepe',
            groupValue: selected,
            enabled: enabled,
            onChanged: onChanged,
            title: 'PhonePe',
            subtitle: 'UPI, Wallet & More',
            icon: Icons.account_balance_wallet,
            iconBackground: theme.colorScheme.secondaryContainer,
            iconColor: theme.colorScheme.secondary,
          ),
          const Divider(height: 1),
          _PaymentOption(
            value: 'razorpay',
            groupValue: selected,
            enabled: enabled,
            onChanged: onChanged,
            title: 'Razorpay',
            subtitle: 'Card, UPI, Net Banking, Wallet',
            icon: Icons.payment,
            iconBackground: theme.colorScheme.primaryContainer,
            iconColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.enabled,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String value;
  final String groupValue;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: enabled ? (v) => onChanged(v!) : null,
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
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
