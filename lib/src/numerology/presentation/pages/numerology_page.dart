import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/razorpay_config.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/numerology/domain/entities/numerology_plan.dart';
import 'package:numberwale/src/numerology/presentation/bloc/numerology_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _orange = Color(0xFFFF8401);
const _navy = Color(0xFF1A1A2E);

/// The numerology consultation form.
///
/// `POST /api/v1/numerology` is a *paid* endpoint: it needs the chosen
/// [NumerologyPlan]'s `serviceType` and a `paymentGateway`, and answers with a
/// payment order that has to be settled before the report is released. The
/// customer's profile must also carry a billing address (for the GST invoice),
/// which the backend reports back as `ADDRESS_REQUIRED`.
class NumerologyPage extends StatelessWidget {
  const NumerologyPage({super.key, required this.plan});

  final NumerologyPlan plan;

  @override
  Widget build(BuildContext context) {
    return _NumerologyView(plan: plan);
  }
}

class _NumerologyView extends StatefulWidget {
  const _NumerologyView({required this.plan});

  final NumerologyPlan plan;

  @override
  State<_NumerologyView> createState() => _NumerologyViewState();
}

class _NumerologyViewState extends State<_NumerologyView> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _purchaseNumberController = TextEditingController();

  String _paymentGateway = 'razorpay';

  late final Razorpay _razorpay;

  /// Id of the numerology request currently being paid for.
  String? _pendingNumerologyId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onRazorpayExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purchaseNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.read<NumerologyBloc>().add(SubmitNumerologyConsultationEvent(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          day: _dayController.text.trim(),
          month: _monthController.text.trim(),
          year: _yearController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          serviceType: widget.plan.serviceType,
          paymentGateway: _paymentGateway,
          purchaseNumber: _purchaseNumberController.text.trim().isEmpty
              ? null
              : _purchaseNumberController.text.trim(),
        ));
  }

  // ── Payment ───────────────────────────────────────────────────────────────

  void _onOrderCreated(NumerologyOrderCreated state) {
    _pendingNumerologyId = state.order.id;

    if (state.paymentGateway == 'phonepe') {
      _openPhonePe(state);
      return;
    }

    final order = state.order.paymentOrder;
    final options = {
      'key': RazorpayConfig.keyId,
      'order_id': order.orderId,
      // The backend hands back a paise amount, which is what the SDK wants.
      'amount': order.amount,
      'currency': order.currency,
      'name': 'Numberwale',
      'description': widget.plan.title,
      'prefill': {
        'name': '${_firstNameController.text.trim()} '
            '${_lastNameController.text.trim()}',
        'email': _emailController.text.trim(),
        'contact': _mobileController.text.trim(),
      },
      'theme': {'color': '#FF8401'},
    };

    log('NUMEROLOGY_RAZORPAY opening with: $options');
    try {
      _razorpay.open(options);
    } catch (e) {
      log('Numerology Razorpay open error: $e');
      _fail('Failed to open payment. Please try again.');
    }
  }

  Future<void> _openPhonePe(NumerologyOrderCreated state) async {
    final url = state.order.paymentOrder.paymentUrl;
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null) {
      _fail('Failed to initiate PhonePe payment. Please try another method.');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _fail('Could not open the PhonePe payment page.');
    }
  }

  void _onRazorpaySuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    final numerologyId = _pendingNumerologyId;
    final paymentId = response.paymentId;
    if (numerologyId == null || paymentId == null) {
      _fail('Payment succeeded but the request could not be confirmed. '
          'Please contact support.');
      return;
    }
    context.read<NumerologyBloc>().add(VerifyNumerologyPaymentEvent(
          numerologyId: numerologyId,
          paymentId: paymentId,
          paymentGateway: 'razorpay',
        ));
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    if (!mounted) return;
    log('Numerology Razorpay error: code=${response.code} '
        'message=${response.message}');
    _fail('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _onRazorpayExternalWallet(ExternalWalletResponse response) {
    log('Numerology Razorpay external wallet: ${response.walletName}');
  }

  /// Shows [message] and returns the form to an editable state.
  void _fail(String message) {
    _pendingNumerologyId = null;
    context.read<NumerologyBloc>().add(const ResetNumerologyEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _onPaymentVerified(NumerologyPaymentVerified state) {
    _pendingNumerologyId = null;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 44),
        title: const Text('Payment Successful'),
        content: Text(state.message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showAddressRequiredDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.location_off_outlined, color: _orange, size: 40),
        title: const Text('Address Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushNamed(context, Routes.addresses);
            },
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = widget.plan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Numerology Consultation'),
        centerTitle: true,
      ),
      body: BlocConsumer<NumerologyBloc, NumerologyState>(
        listener: (context, state) {
          if (state is NumerologyOrderCreated) {
            _onOrderCreated(state);
          } else if (state is NumerologyPaymentVerified) {
            _onPaymentVerified(state);
          } else if (state is NumerologyError) {
            if (state.message.contains('billing address')) {
              _showAddressRequiredDialog(state.message);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isBusy = state is NumerologyLoading ||
              state is NumerologyOrderCreated ||
              state is NumerologyVerifyingPayment;

          return AbsorbPointer(
            absorbing: isBusy,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanSummary(plan: plan),
                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.person_outline,
                      title: 'Your Details',
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _validateName(v, 'First'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => _validateName(v, 'Last'),
                    ),
                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.cake_outlined,
                      title: 'Date of Birth',
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dayController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 2,
                            decoration: const InputDecoration(
                              labelText: 'Day *',
                              border: OutlineInputBorder(),
                              counterText: '',
                              hintText: '1-31',
                            ),
                            validator: _validateDay,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _monthController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 2,
                            decoration: const InputDecoration(
                              labelText: 'Month *',
                              border: OutlineInputBorder(),
                              counterText: '',
                              hintText: '1-12',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              final month = int.tryParse(v.trim());
                              if (month == null || month < 1 || month > 12) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 4,
                            decoration: const InputDecoration(
                              labelText: 'Year *',
                              border: OutlineInputBorder(),
                              counterText: '',
                              hintText: 'YYYY',
                            ),
                            validator: _validateYear,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.contact_phone_outlined,
                      title: 'Contact Details',
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Mobile *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (v) => _validateMobile(v, required: true),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(v.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _purchaseNumberController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: plan.requiresAnalyzeNumber
                            ? 'Mobile Number to Analyze *'
                            : 'Mobile Number to Analyze (Optional)',
                        prefixIcon: const Icon(Icons.sim_card_outlined),
                        border: const OutlineInputBorder(),
                        counterText: '',
                        helperText: plan.requiresAnalyzeNumber
                            ? 'The number this report will be based on'
                            : null,
                      ),
                      validator: (v) => _validateMobile(
                        v,
                        required: plan.requiresAnalyzeNumber,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment Method',
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _GatewaySelector(
                      selected: _paymentGateway,
                      onChanged: (gateway) =>
                          setState(() => _paymentGateway = gateway),
                    ),
                    const SizedBox(height: 28),

                    FilledButton(
                      onPressed: isBusy ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Pay ₹${plan.price} & Get Report',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state is NumerologyVerifyingPayment
                          ? 'Confirming your payment…'
                          : 'Secure payment • GST invoice included',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateName(String? v, String label) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return '$label name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters';
    }
    return null;
  }

  String? _validateMobile(String? v, {required bool required}) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) {
      return required ? 'Mobile number is required' : null;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid 10-digit number starting with 6-9';
    }
    return null;
  }

  String? _validateDay(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Required';
    final day = int.tryParse(value);
    if (day == null || day < 1 || day > 31) return 'Invalid';

    // Reject e.g. 31 February once month and year are both filled in.
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());
    if (month != null && month >= 1 && month <= 12 && year != null) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (day > daysInMonth) return 'Max $daysInMonth';
    }
    return null;
  }

  String? _validateYear(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Required';
    final year = int.tryParse(value);
    final thisYear = DateTime.now().year;
    if (year == null) return 'Invalid';
    if (year > thisYear) return 'Future';
    if (year < thisYear - 100) return 'Invalid';
    return null;
  }
}

/// Reminds the customer which report they're buying and what it costs.
class _PlanSummary extends StatelessWidget {
  const _PlanSummary({required this.plan});

  final NumerologyPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              plan.badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            plan.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            plan.subtitle,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const Divider(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Base ₹${plan.basePrice} + GST (18%) ₹${plan.gst}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              Text(
                '₹${plan.price}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GatewaySelector extends StatelessWidget {
  const _GatewaySelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GatewayTile(
            label: 'Razorpay',
            caption: 'Cards, UPI, Netbanking',
            icon: Icons.credit_card,
            isSelected: selected == 'razorpay',
            onTap: () => onChanged('razorpay'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GatewayTile(
            label: 'PhonePe',
            caption: 'UPI & wallet',
            icon: Icons.account_balance_wallet_outlined,
            isSelected: selected == 'phonepe',
            onTap: () => onChanged('phonepe'),
          ),
        ),
      ],
    );
  }
}

class _GatewayTile extends StatelessWidget {
  const _GatewayTile({
    required this.label,
    required this.caption,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _orange : Colors.grey.shade300,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: isSelected ? _orange : Colors.grey),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isSelected ? _orange : _navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Divider(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          thickness: 1,
        ),
      ],
    );
  }
}
