import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/razorpay_config.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/address_card.dart';
import 'package:numberwale/core/widgets/cart_summary_card.dart';
import 'package:numberwale/core/widgets/product_list_item.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/cart_validation_result.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_confirmation_result.dart';
import 'package:numberwale/src/cart/domain/entities/phonepe_verification_result.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({
    super.key,
    required this.deliveryAddress,
  });

  final Map<String, dynamic> deliveryAddress;

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage>
    with WidgetsBindingObserver {
  late final Razorpay _razorpay;
  Cart? _cart;

  // Set while re-validating after auto-removing unavailable items, so we
  // show a plain error instead of the removal dialog again if it still fails.
  bool _isRetryValidation = false;

  // Set once a PhonePe payment page has been opened externally. Used both to
  // know a verification is due on resume, and to supply the order amount
  // once verification completes (the verify response doesn't include it).
  CheckoutResult? _pendingPhonePeCheckout;
  bool _awaitingPhonePeResume = false;

  // Set once /cart/checkout has created a Razorpay order, so
  // _onRazorpaySuccess and _onPaymentConfirmed know the orderId/amount to
  // use (the Razorpay SDK response and /cart/payment-success response don't
  // carry the amount).
  CheckoutResult? _pendingRazorpayCheckout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onRazorpayExternalWallet);

    final currentState = context.read<CartBloc>().state;
    if (currentState is CartLoaded) {
      _cart = currentState.cart;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _razorpay.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_awaitingPhonePeResume) return;
    final pending = _pendingPhonePeCheckout;
    if (pending == null) return;

    // Only verify once per redirect — clear the flag before dispatching so
    // backgrounding the app again later (e.g. while "Processing...") doesn't
    // re-trigger verification. _pendingPhonePeCheckout itself is kept around
    // so _onPhonePePaymentVerified can still read its amount.
    _awaitingPhonePeResume = false;
    context
        .read<CartBloc>()
        .add(VerifyPhonePePaymentEvent(orderId: pending.orderId));
  }

  // ── Razorpay ──────────────────────────────────────────────────────────────
  // /cart/checkout only *creates* the Razorpay order — it does not collect
  // or confirm payment. Flow:
  //   1. Dispatch CheckoutEvent(paymentGateway: 'razorpay')
  //   2. Backend creates a Razorpay order → returns orderId + amount
  //   3. BLoC emits RazorpayCheckoutReady
  //   4. _openRazorpay opens the SDK with that orderId (not just amount/key)
  //   5. On SDK success, dispatch ConfirmPaymentEvent →
  //      POST /cart/payment-success, which actually finalizes the order

  void _initiateRazorpayCheckout() {
    final addressId = widget.deliveryAddress['id'] as String? ?? '';
    context.read<CartBloc>().add(
          CheckoutEvent(addressId: addressId, paymentGateway: 'razorpay'),
        );
  }

  void _openRazorpay(RazorpayCheckoutReady state) {
    _pendingRazorpayCheckout = state.checkoutResult;
    final options = {
      'key': RazorpayConfig.keyId,
      'order_id': state.checkoutResult.orderId,
      // CheckoutResult.amount is rupees (CheckoutResultModel normalizes the
      // backend's paise value) — convert back to paise for the SDK. Verified
      // against a real order: payment.payableAmount was 6040 (rupees) and
      // /cart/checkout's raw amount was 604000 — the SDK needs that paise
      // figure, not the rupee one.
      'amount': (state.checkoutResult.amount * 100).toInt(),
      'name': 'Numberwale',
      'description': 'VIP Phone Number Purchase',
      'currency': state.checkoutResult.currency,
      'theme': {'color': '#6750A4'},
    };
    log('RAZORPAY_DEBUG opening with: $options');
    try {
      _razorpay.open(options);
    } catch (e) {
      log('Razorpay open error: $e');
      _showError('Failed to open payment. Please try again.');
    }
  }

  void _onRazorpaySuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    log('Razorpay success: paymentId=${response.paymentId}');

    final paymentId = response.paymentId;
    final orderId = response.orderId ?? _pendingRazorpayCheckout?.orderId;
    if (paymentId == null || orderId == null) {
      _showError('Payment succeeded but the order could not be confirmed. '
          'Please contact support.');
      return;
    }

    context.read<CartBloc>().add(ConfirmPaymentEvent(
          paymentId: paymentId,
          orderId: orderId,
          gateway: 'razorpay',
        ));
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    if (!mounted) return;
    log('Razorpay error: code=${response.code} message=${response.message}');
    _showError(
      'Payment failed: '
      // 'Payment failed (code ${response.code}): '
      '${response.message ?? 'Unknown error'}',
    );
  }

  void _onRazorpayExternalWallet(ExternalWalletResponse response) {
    log('Razorpay external wallet: ${response.walletName}');
  }

  void _onPaymentConfirmed(PaymentConfirmationResult result) {
    final checkout = _pendingRazorpayCheckout;
    _pendingRazorpayCheckout = null;

    Navigator.pushReplacementNamed(
      context,
      Routes.orderSuccess,
      arguments: {
        'orderId': result.orderId,
        'orderNumber': result.orderNumber,
        'amount': checkout?.amount,
      },
    );
  }

  // ── PhonePe ───────────────────────────────────────────────────────────────
  // This backend has no PhonePe SDK token flow — /cart/checkout returns a
  // hosted payment page URL instead. Flow:
  //   1. Dispatch CheckoutEvent(paymentGateway: 'phonepe')
  //   2. Backend creates a PhonePe order → returns orderId + paymentUrl
  //   3. BLoC emits PhonePeRedirectReady
  //   4. _openPhonePeRedirect opens paymentUrl externally (browser/app)
  //   5. When the user returns to the app, didChangeAppLifecycleState fires
  //      VerifyPhonePePaymentEvent, which polls /cart/verify-phonepe-payment

  void _initiatePhonePeCheckout() {
    final addressId = widget.deliveryAddress['id'] as String? ?? '';
    context.read<CartBloc>().add(
          CheckoutEvent(addressId: addressId, paymentGateway: 'phonepe'),
        );
  }

  Future<void> _openPhonePeRedirect(PhonePeRedirectReady state) async {
    final uri = Uri.tryParse(state.paymentUrl);
    if (uri == null) {
      _showError('Received an invalid PhonePe payment link.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;

    if (!launched) {
      _showError('Unable to open PhonePe. Please try again.');
      return;
    }

    // Verification is triggered by didChangeAppLifecycleState when the user
    // comes back to the app after completing (or abandoning) payment.
    _pendingPhonePeCheckout = state.checkoutResult;
    _awaitingPhonePeResume = true;
  }

  void _onPhonePePaymentVerified(PhonePeVerificationResult result) {
    final checkout = _pendingPhonePeCheckout;
    _pendingPhonePeCheckout = null;

    switch (result.status) {
      case PhonePePaymentStatus.completed:
        Navigator.pushReplacementNamed(
          context,
          Routes.orderSuccess,
          arguments: {
            'orderId': result.orderId ?? checkout?.orderId,
            'orderNumber': result.orderNumber ?? checkout?.orderNumber,
            'amount': checkout?.amount,
          },
        );
      case PhonePePaymentStatus.failed:
        _showError(result.message);
      case PhonePePaymentStatus.pending:
        _showInfo(
          "${result.message} We'll update your order once payment is confirmed.",
        );
    }
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Entry point for the "Proceed to Payment" button. Validates the cart
  /// (availability + pricing) before opening the payment gateway sheet, so
  /// checkout doesn't fail on items that became unavailable or changed price.
  void _startCheckout(BuildContext context) {
    _isRetryValidation = false;
    context.read<CartBloc>().add(const ValidateCartEvent());
  }

  void _proceedToPayment(double amount) {
    if (amount <= 0) {
      _showError('Unable to determine payment amount.');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _PaymentGatewaySheet(
        onSelected: (gateway) {
          Navigator.pop(sheetContext);
          if (gateway == 'razorpay') {
            _initiateRazorpayCheckout();
          } else {
            _initiatePhonePeCheckout();
          }
        },
      ),
    );
  }

  void _onCartValidationCompleted(CartValidationResult result) {
    // result.cart reflects the server's current, authoritative pricing —
    // adopt it so what we display/charge from stays in sync with what
    // /cart/checkout will actually bill.
    setState(() => _cart = result.cart);

    if (result.isValid) {
      _proceedToPayment(result.cart.totalAmount);
      return;
    }

    if (_isRetryValidation) {
      // Already tried removing the unavailable items once — don't loop.
      _showError(
        'Some items are still unavailable: '
        '${result.invalidItems.map((i) => i.message).join(', ')}',
      );
      return;
    }

    _showInvalidItemsDialog(result.invalidItems);
  }

  void _showInvalidItemsDialog(List<CartItemValidation> invalidItems) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Some items are unavailable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in invalidItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_numberFor(item.productId)}: ${item.message}',
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _removeInvalidItemsAndRetry(invalidItems);
            },
            child: const Text('Remove & Continue'),
          ),
        ],
      ),
    );
  }

  String _numberFor(String productId) {
    final match = _cart?.items.where((i) => i.productId == productId);
    return match != null && match.isNotEmpty
        ? match.first.productNumber
        : productId;
  }

  Future<void> _removeInvalidItemsAndRetry(
    List<CartItemValidation> invalidItems,
  ) async {
    final cartBloc = context.read<CartBloc>();

    // Remove sequentially and wait for each to finish — the bloc doesn't
    // guarantee event ordering otherwise, and validating too early would
    // just find the same items still unavailable.
    for (final item in invalidItems) {
      cartBloc.add(RemoveCartItemEvent(itemId: item.productId));
      final removeResult = await cartBloc.stream
          .firstWhere((s) => s is ItemRemovedFromCart || s is CartError);
      if (!mounted) return;
      if (removeResult is CartError) {
        _showError(removeResult.message);
        return;
      }
    }

    _isRetryValidation = true;
    cartBloc.add(const ValidateCartEvent());
  }

  void _onCartStateChange(BuildContext context, CartState state) {
    if (state is CartLoaded) {
      setState(() => _cart = state.cart);
    } else if (state is CartValidationCompleted) {
      _onCartValidationCompleted(state.result);
    } else if (state is PhonePeRedirectReady) {
      _openPhonePeRedirect(state);
    } else if (state is PhonePePaymentVerified) {
      _onPhonePePaymentVerified(state.result);
    } else if (state is RazorpayCheckoutReady) {
      _openRazorpay(state);
    } else if (state is PaymentConfirmed) {
      _onPaymentConfirmed(state.result);
    } else if (state is CheckoutComplete) {
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
      _showError(state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CartBloc, CartState>(
      listener: _onCartStateChange,
      child: Scaffold(
        appBar: AppBar(title: const Text('Order Summary')),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final isLoading = state is CheckingOut ||
                state is PhonePeRedirectReady ||
                state is VerifyingPhonePePayment ||
                state is RazorpayCheckoutReady ||
                state is ConfirmingPayment ||
                state is CartValidating;
            final items = _cart?.items ?? [];
            final subtotal = _cart?.subtotal ?? 0;
            final totalAmount = _cart?.totalAmount ?? 0;

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
                        addressLine1: widget.deliveryAddress['addressLine1'],
                        addressLine2: widget.deliveryAddress['addressLine2'],
                        landmark: widget.deliveryAddress['landmark'],
                        city: widget.deliveryAddress['city'],
                        state: widget.deliveryAddress['state'],
                        pinCode: widget.deliveryAddress['pinCode'],
                        isPrimary: widget.deliveryAddress['isPrimary'] ?? false,
                        showActions: false,
                        onTap: () => Navigator.pop(context),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Order Items (${items.length})',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ProductListItem(
                            phoneNumber: item.productNumber,
                            price: item.price,
                            category: 'Phone Number',
                            features: const [],
                            isFeatured: false,
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.productDetail,
                              arguments: item.productNumber,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      CartSummaryCard(
                        subtotal: subtotal,
                        cgst: _cart?.cgst,
                        sgst: _cart?.sgst,
                        totalAmount: totalAmount > 0 ? totalAmount : null,
                      ),
                    ],
                  ),
                ),

                _BottomBar(
                  isLoading: isLoading,
                  onTap: () => _startCheckout(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PaymentGatewaySheet extends StatelessWidget {
  const _PaymentGatewaySheet({required this.onSelected});

  final void Function(String gateway) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Payment Method',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you would like to pay',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _GatewayTile(
            label: 'Razorpay',
            subtitle: 'Cards, UPI, Net Banking & more',
            icon: Icons.credit_card_rounded,
            color: const Color(0xFF2D81F7),
            onTap: () => onSelected('razorpay'),
          ),
          const SizedBox(height: 12),
          _GatewayTile(
            label: 'PhonePe',
            subtitle: 'UPI & PhonePe Wallet',
            icon: Icons.phone_android_rounded,
            color: const Color(0xFF5F259F),
            onTap: () => onSelected('phonepe'),
          ),
        ],
      ),
    );
  }
}

class _GatewayTile extends StatelessWidget {
  const _GatewayTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
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
