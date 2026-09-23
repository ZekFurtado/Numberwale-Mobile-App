import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/razorpay_config.dart';
import 'package:numberwale/core/utils/route_observer.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/cart_item_card.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';
import 'package:numberwale/src/address/presentation/bloc/address_bloc.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:numberwale/src/cart/domain/entities/cart.dart';
import 'package:numberwale/src/cart/domain/entities/cart_validation_result.dart';
import 'package:numberwale/src/cart/domain/entities/checkout_result.dart';
import 'package:numberwale/src/cart/domain/entities/payment_confirmation_result.dart';
import 'package:numberwale/src/cart/domain/entities/phonepe_verification_result.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/profile/presentation/bloc/profile_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _orange = Color(0xFFFF8401);
const _cardBorder = Color(0xFFFFD9B3);
const _pillCream = Color(0xFFFFF7ED);
const _cream = Color(0xFFFFF8F2);

/// The cart page mirrors numberwale.com's shopping-cart screen: item cards,
/// profile + delivery-address summary, order totals, an inline payment
/// method picker and the checkout action all live on this one page — there
/// is no separate address-selection or order-summary step. "Change" on the
/// address card still opens [AddressSelectionPage] to pick a different
/// saved address, but that page now just sets it as primary and returns
/// here instead of continuing a multi-page checkout wizard.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with RouteAware, WidgetsBindingObserver {
  late final Razorpay _razorpay;
  Cart? _cart;
  final _couponController = TextEditingController();
  String _selectedGateway = 'razorpay';

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

  void _refreshCart() {
    context.read<CartBloc>().add(const LoadCartEvent());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onRazorpayExternalWallet);

    final currentCartState = context.read<CartBloc>().state;
    if (currentCartState is CartLoaded) {
      _cart = currentCartState.cart;
    }
    _refreshCart();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
    context.read<AddressBloc>().add(const GetAddressesEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // CartBloc is app-wide and may be sitting on a transient state left
    // behind by checkout (e.g. CartValidating) when the user navigates back
    // here — refresh so the cart actually shows again instead of getting
    // stuck on the loading fallback.
    _refreshCart();
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

  // ── Address / profile navigation ────────────────────────────────────────

  Future<void> _addNewAddress() async {
    await Navigator.pushNamed(context, Routes.addressForm);
    if (mounted) {
      context.read<AddressBloc>().add(const GetAddressesEvent());
    }
  }

  Future<void> _changeAddress() async {
    await Navigator.pushNamed(context, Routes.addressSelection);
  }

  Address? _currentAddress() {
    final state = context.read<AddressBloc>().state;
    if (state is! AddressesLoaded || state.addresses.isEmpty) return null;
    final addresses = state.addresses;
    return addresses.any((a) => a.isPrimary)
        ? addresses.firstWhere((a) => a.isPrimary)
        : addresses.first;
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

  void _openRazorpay(RazorpayCheckoutReady state) {
    _pendingRazorpayCheckout = state.checkoutResult;
    final options = {
      'key': RazorpayConfig.keyId,
      'order_id': state.checkoutResult.orderId,
      'amount': (state.checkoutResult.amount * 100).toInt(),
      'name': 'Numberwale',
      'description': 'VIP Phone Number Purchase',
      'currency': state.checkoutResult.currency,
      'theme': {'color': '#FF8401'},
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
    _showError('Payment failed: ${response.message ?? 'Unknown error'}');
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

  // ── Checkout ──────────────────────────────────────────────────────────────

  void _startCheckout() {
    final address = _currentAddress();
    if (address == null) {
      _showError('Please add a delivery address to continue.');
      _addNewAddress();
      return;
    }
    _isRetryValidation = false;
    context.read<CartBloc>().add(const ValidateCartEvent());
  }

  void _onCartValidationCompleted(CartValidationResult result) {
    // result.cart reflects the server's current, authoritative pricing —
    // adopt it so what we display/charge from stays in sync with what
    // /cart/checkout will actually bill.
    setState(() => _cart = result.cart);

    if (result.isValid) {
      _proceedToPayment();
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

  void _proceedToPayment() {
    final address = _currentAddress();
    final addressId = address?.id;
    if (addressId == null) {
      _showError('Please add a delivery address to continue.');
      return;
    }
    context.read<CartBloc>().add(
          CheckoutEvent(addressId: addressId, paymentGateway: _selectedGateway),
        );
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
                child: Text('${_numberFor(item.productId)}: ${item.message}'),
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

  void _applyCoupon() {
    if (_couponController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coupon codes are not available yet')),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartBloc>().add(const ClearCartEvent());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onCartStateChange(BuildContext context, CartState state) {
    if (state is CartLoaded) {
      setState(() => _cart = state.cart);
    } else if (state is ItemRemovedFromCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (state is CartCleared) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cart cleared')));
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
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_cart?.isNotEmpty == true)
            IconButton(
              onPressed: _showClearCartDialog,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CartBloc, CartState>(listener: _onCartStateChange),
          BlocListener<AddressBloc, AddressState>(
            listener: (context, state) {
              if (state is AddressError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final cart = _cart;

            if (cart == null) {
              if (state is CartError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _refreshCart,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }

            if (cart.isEmpty) {
              return EmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'Your Cart is Empty',
                message:
                    'Add some premium numbers to your cart to get started!',
                actionLabel: 'Explore Numbers',
                onAction: () => Navigator.pop(context),
              );
            }

            final isLoading = state is CheckingOut ||
                state is PhonePeRedirectReady ||
                state is VerifyingPhonePePayment ||
                state is RazorpayCheckoutReady ||
                state is ConfirmingPayment ||
                state is CartValidating;

            return _buildCartContent(context, cart, isLoading);
          },
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, Cart cart, bool isLoading) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          _CartHeader(itemCount: cart.itemCount),
          const SizedBox(height: 24),
          for (final item in cart.items)
            CartItemCard(
              phoneNumber: item.productNumber,
              price: item.price,
              category: item.category,
              numerology: item.numerology,
              onRemove: () => context.read<CartBloc>().add(
                    RemoveCartItemEvent(itemId: item.id ?? item.productId),
                  ),
              onTap: () => Navigator.pushNamed(
                context,
                Routes.productDetail,
                arguments: item.productNumber,
              ),
            ),
          const SizedBox(height: 8),
          _ProfileAddressCard(
            onAddAddress: _addNewAddress,
            onChangeAddress: _changeAddress,
          ),
          const SizedBox(height: 20),
          _OrderSummarySection(
            cart: cart,
            selectedGateway: _selectedGateway,
            onGatewaySelected: (gateway) =>
                setState(() => _selectedGateway = gateway),
            couponController: _couponController,
            onApplyCoupon: _applyCoupon,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLoading ? null : _startCheckout,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(isLoading ? 'Processing...' : 'Proceed to Checkout'),
              style: FilledButton.styleFrom(
                backgroundColor: _orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.canPop(context)
                  ? Navigator.pop(context)
                  : Navigator.pushReplacementNamed(context, Routes.home),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Continue shopping'),
              style: TextButton.styleFrom(foregroundColor: Colors.black54),
            ),
          ),
          const SizedBox(height: 36),
          _PremiumJourneySection(isLoading: isLoading, onCheckout: _startCheckout),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 14, color: _orange),
            SizedBox(width: 6),
            Text(
              'SECURE CHECKOUT',
              style: TextStyle(
                color: _orange,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'SHOPPING CART',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'} added',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileAddressCard extends StatelessWidget {
  const _ProfileAddressCard({
    required this.onAddAddress,
    required this.onChangeAddress,
  });

  final VoidCallback onAddAddress;
  final VoidCallback onChangeAddress;

  @override
  Widget build(BuildContext context) {
    var name = '';
    var email = '';
    var phone = '';

    final authState = context.watch<AuthenticationBloc>().state;
    final fallbackUser = authState is LoggedIn
        ? authState.user
        : authState is OTPVerified
            ? authState.user
            : null;
    if (fallbackUser != null) {
      name = fallbackUser.name ?? '';
      email = fallbackUser.email ?? '';
      phone = fallbackUser.phone != null ? '+91 ${fallbackUser.phone}' : '';
    }

    final profileState = context.watch<ProfileBloc>().state;
    if (profileState is ProfileLoaded || profileState is ProfileUpdated) {
      final profile = profileState is ProfileLoaded
          ? profileState.profile
          : (profileState as ProfileUpdated).profile;
      name = profile.name;
      email = profile.email;
      phone = '+91 ${profile.mobile}';
    }

    final addressState = context.watch<AddressBloc>().state;
    final addresses =
        addressState is AddressesLoaded ? addressState.addresses : const <Address>[];
    final address = addresses.isEmpty
        ? null
        : (addresses.any((a) => a.isPrimary)
            ? addresses.firstWhere((a) => a.isPrimary)
            : addresses.first);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _InfoColumn(
                  icon: Icons.person_outline,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF3B82F6),
                  label: 'PROFILE',
                  actionLabel: 'EDIT',
                  onAction: () => Navigator.pushNamed(context, Routes.editProfile),
                  child: name.isEmpty
                      ? const Text('Loading...', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (phone.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(phone,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              ),
                            if (email.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  email,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFF3F4F6)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _InfoColumn(
                  icon: Icons.location_on_outlined,
                  iconBg: const Color(0xFFF0FDF4),
                  iconColor: const Color(0xFF22C55E),
                  label: 'ADDRESS',
                  actionLabel: address == null ? 'ADD' : 'CHANGE',
                  onAction: address == null ? onAddAddress : onChangeAddress,
                  child: address == null
                      ? const Text('No address added',
                          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)))
                      : Text(
                          '${address.addressLine1}, ${address.city}\n${address.state} - ${address.pinCode}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.actionLabel,
    required this.onAction,
    required this.child,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _orange),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

String _formatMoney(double price) {
  final fixed = price.toStringAsFixed(2);
  final dotIndex = fixed.indexOf('.');
  final wholePart = fixed.substring(0, dotIndex);
  final decimalPart = fixed.substring(dotIndex);

  final buffer = StringBuffer();
  for (var i = 0; i < wholePart.length; i++) {
    if (i > 0 && (wholePart.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(wholePart[i]);
  }

  return '₹$buffer$decimalPart';
}

class _OrderSummarySection extends StatelessWidget {
  const _OrderSummarySection({
    required this.cart,
    required this.selectedGateway,
    required this.onGatewaySelected,
    required this.couponController,
    required this.onApplyCoupon,
  });

  final Cart cart;
  final String selectedGateway;
  final ValueChanged<String> onGatewaySelected;
  final TextEditingController couponController;
  final VoidCallback onApplyCoupon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _pillCream, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_outlined, size: 16, color: _orange),
              ),
              const SizedBox(width: 10),
              const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Subtotal', value: _formatMoney(cart.subtotal)),
          const SizedBox(height: 10),
          _SummaryRow(label: 'CGST (9%)', value: _formatMoney(cart.cgst)),
          const SizedBox(height: 10),
          _SummaryRow(label: 'SGST (9%)', value: _formatMoney(cart.sgst)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter Coupon Code',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: onApplyCoupon,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4B5563),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('APPLY',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Payment Method',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF374151))),
          const SizedBox(height: 10),
          _PaymentGatewayTile(
            label: 'Razorpay',
            subtitle: 'Cards, UPI, Net Banking & more',
            icon: Icons.credit_card_rounded,
            color: const Color(0xFF2D81F7),
            selected: selectedGateway == 'razorpay',
            onTap: () => onGatewaySelected('razorpay'),
          ),
          const SizedBox(height: 12),
          _PaymentGatewayTile(
            label: 'PhonePe',
            subtitle: 'UPI & PhonePe Wallet',
            icon: Icons.phone_android_rounded,
            color: const Color(0xFF5F259F),
            selected: selectedGateway == 'phonepe',
            onTap: () => onGatewaySelected('phonepe'),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatMoney(cart.totalAmount),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const Text(
                      'INCLUDING ALL TAXES',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}

class _PaymentGatewayTile extends StatelessWidget {
  const _PaymentGatewayTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _pillCream : Colors.white,
          border: Border.all(
            color: selected ? _orange : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _orange : Colors.transparent,
                border: Border.all(
                  color: selected ? _orange : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStepData {
  const _JourneyStepData({
    required this.icon,
    required this.label,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String title;
  final String description;
}

const _journeySteps = [
  _JourneyStepData(
    icon: Icons.credit_card,
    label: 'STEP 1',
    title: 'Secure Payment',
    description:
        'Complete your payment securely through multiple options including UPI, cards, and net banking',
  ),
  _JourneyStepData(
    icon: Icons.qr_code_2,
    label: 'STEP 2',
    title: 'UPC Delivery',
    description:
        'Receive your Unique Port Code via SMS, WhatsApp & email within 24 hours of confirmed payment',
  ),
  _JourneyStepData(
    icon: Icons.badge_outlined,
    label: 'STEP 3',
    title: 'MNP Initiation',
    description:
        "Visit your preferred operator's store with your ID proof and UPC to start the MNP process",
  ),
  _JourneyStepData(
    icon: Icons.smartphone_outlined,
    label: 'STEP 4',
    title: 'SIM Activation',
    description:
        'Your new SIM activates in 4-5 business days nationwide (up to 15 days for specific regions)',
  ),
  _JourneyStepData(
    icon: Icons.replay_circle_filled_outlined,
    label: 'OUR PROMISE',
    title: '100% Money Back',
    description:
        'Guaranteed full refund if you encounter any issues with UPC delivery or number activation',
  ),
];

class _PremiumJourneySection extends StatelessWidget {
  const _PremiumJourneySection({required this.isLoading, required this.onCheckout});

  final bool isLoading;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _pillCream,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cardBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 6, color: _orange),
              SizedBox(width: 8),
              Text(
                'SIMPLE & FAST',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black, height: 1.25),
            children: [
              TextSpan(text: 'Your Premium Number\n'),
              TextSpan(text: 'Journey', style: TextStyle(color: _orange)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'From selection to activation in just a few simple steps - our streamlined '
          'process ensures you get your VIP number quickly and hassle-free',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < _journeySteps.length; i++)
          _JourneyStepRow(
            data: _journeySteps[i],
            index: i + 1,
            isLast: i == _journeySteps.length - 1,
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
              SizedBox(width: 10),
              Text('Average delivery time: 24 hours',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isLoading ? null : onCheckout,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.shopping_cart_outlined),
            label: Text(isLoading ? 'Processing...' : 'Secure Your Premium Number Now'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 13, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 6),
            Text(
              'SECURE CHECKOUT WITH 256-BIT ENCRYPTION',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JourneyStepRow extends StatelessWidget {
  const _JourneyStepRow({required this.data, required this.index, required this.isLast});

  final _JourneyStepData data;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: _cardBorder, width: 1.5),
                    ),
                    child: Icon(data.icon, color: const Color(0xFF9CA3AF), size: 22),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF111827)),
                      child: Text(
                        '$index',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: _cardBorder,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 28, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: const TextStyle(color: _orange, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(data.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 6),
                  Text(
                    data.description,
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4),
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
