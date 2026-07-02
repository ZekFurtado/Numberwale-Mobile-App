import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

/// Mirrors numberwale.com/premium-numbers/{number} — see product_detail_page
/// screenshots this was built from.
const _orange = Color(0xFFFF8401);
const _darkButton = Color(0xFF2D3748);
const _green = Color(0xFF047857);
const _greenBg = Color(0xFFECFDF5);
const _blue = Color(0xFF1D4ED8);
const _blueBg = Color(0xFFEFF6FF);
const _amber = Color(0xFFC2410C);
const _amberBg = Color(0xFFFFF7ED);
const _purple = Color(0xFF7C3AED);
const _purpleBg = Color(0xFFF5F3FF);
const _peachBg = Color(0xFFFDF4EA);
const _pageBg = Color(0xFFF7F5F2);

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return _ProductDetailView(phoneNumber: phoneNumber);
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView({required this.phoneNumber});

  final String phoneNumber;

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  bool _isAddingToCart = false;
  bool _isBuyingNow = false;
  bool _isWishlisted = false;
  int? _expandedFaqIndex;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listenWhen: (_, current) =>
          current is CartLoaded || current is CartError,
      listener: (context, state) {
        if (!_isAddingToCart && !_isBuyingNow) return;
        if (state is CartLoaded) {
          final wasBuyingNow = _isBuyingNow;
          setState(() {
            _isAddingToCart = false;
            _isBuyingNow = false;
          });
          if (wasBuyingNow) {
            Navigator.pushNamed(context, Routes.cart);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Added to cart'),
                action: SnackBarAction(
                  label: 'View Cart',
                  onPressed: () => Navigator.pushNamed(context, Routes.cart),
                ),
              ),
            );
          }
        } else if (state is CartError) {
          setState(() {
            _isAddingToCart = false;
            _isBuyingNow = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, _) => BlocBuilder<ProductBloc, ProductState>(
        builder: _buildContent,
      ),
    );
  }

  String _rtpLabel(PhoneNumber product) {
    if (product.isRTP) return 'Ready to Port';
    if (product.isCRTP) return 'Conditionally Ready to Port';
    return 'Verification Required';
  }

  void _addToCart(PhoneNumber product) {
    setState(() => _isAddingToCart = true);
    context.read<CartBloc>().add(AddToCartEvent(productId: product.id!));
  }

  // "Buy Now" adds this number to whatever's already in the cart, then
  // takes the user straight to the cart page — where they can delete any
  // items they don't want before checking out.
  void _buyNow(PhoneNumber product) {
    setState(() => _isBuyingNow = true);
    context.read<CartBloc>().add(AddToCartEvent(productId: product.id!));
  }

  void _goToExplore() {
    Navigator.of(context)
        .popUntil((route) => route.settings.name == Routes.appShell);
    context.read<AppNavigationCubit>().selectTab(1);
  }

  Widget _buildContent(BuildContext context, ProductState state) {
    if (state is ProductLoading || state is ProductInitial) {
      return Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: CircularProgressIndicator(color: _orange)),
      );
    }

    if (state is ProductError) {
      return Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context
                    .read<ProductBloc>()
                    .add(LoadProductByNumberEvent(number: widget.phoneNumber)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! ProductDetailLoaded) {
      return Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: CircularProgressIndicator(color: _orange)),
      );
    }

    final product = state.product;
    final numerology = product.numerology;
    final literSum = numerology?['liters'] as int?;
    final trapSum = numerology?['trap'] as int?;
    final scoreSum = numerology?['score'] as int?;

    final basePrice = product.price;
    final gst = basePrice * 0.18;
    final cgst = gst / 2;
    final total = basePrice + gst;

    final canBuy = product.id != null &&
        product.isAvailable &&
        !_isAddingToCart &&
        !_isBuyingNow;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        titleSpacing: 0,
        title: _Breadcrumb(number: product.number),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, Routes.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _MainCard(
                product: product,
                literSum: literSum,
                trapSum: trapSum,
                scoreSum: scoreSum,
                basePrice: basePrice,
                gst: gst,
                cgst: cgst,
                total: total,
                rtpLabel: _rtpLabel(product),
                isWishlisted: _isWishlisted,
                onWishlistToggle: () =>
                    setState(() => _isWishlisted = !_isWishlisted),
                onShare: () => Share.share(
                  'Check out this premium number: ${product.number}\n'
                  'Available at Numberwale',
                  subject: 'Premium Mobile Number',
                ),
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: product.number));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Number copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                isAddingToCart: _isAddingToCart,
                isBuyingNow: _isBuyingNow,
                canBuy: canBuy,
                onAddToCart: () => _addToCart(product),
                onBuyNow: () => _buyNow(product),
              ),
            ),
            const SizedBox(height: 24),
            _AboutSection(product: product),
            /*const SizedBox(height: 24),
            _RelatedNumbersSection(
              title: 'Numbers Ending with ${_lastDigits(product.number, 5)}',
              subtitle: 'Discover more premium numbers ending with the same digits',
            ),
            const SizedBox(height: 24),
            _RelatedNumbersSection(
              title: 'More ${product.category} Numbers',
              subtitle: 'Browse our extensive collection of '
                  '${product.category.toLowerCase()} VIP numbers',
              trailing: _ViewAllCard(onTap: _goToExplore),
            ),*/
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _WhyChooseCategoryCard(category: product.category),
            ),
            const SizedBox(height: 32),
            _FaqSection(
              product: product,
              rtpLabel: _rtpLabel(product),
              total: total,
              expandedIndex: _expandedFaqIndex,
              onToggle: (index) => setState(() {
                _expandedFaqIndex = _expandedFaqIndex == index ? null : index;
              }),
            ),
            const SizedBox(height: 32),
            /*_ExplorePatternsSection(onTap: _goToExplore),
            const SizedBox(height: 32),*/
            const _NetworksSection(),
            const SizedBox(height: 32),
            _CitiesSection(category: product.category, onTap: _goToExplore),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

String _lastDigits(String number, int count) {
  return number.length <= count
      ? number
      : number.substring(number.length - count);
}

String _formatNumber(String number) {
  if (number.length == 10) {
    return '${number.substring(0, 5)} ${number.substring(5)}';
  }
  return number;
}

String _formatRupees(double amount) {
  final s = amount.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0 && (s.length - i) != 0) {
      buffer.write(',');
    }
    buffer.write(s[i]);
  }
  return buffer.toString();
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(Icons.home_outlined, size: 16, color: Color(0xFF6B7280)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Text(
            'Premium Numbers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _orange.withValues(alpha: 0.3)),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: _orange,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainCard extends StatelessWidget {
  const _MainCard({
    required this.product,
    required this.literSum,
    required this.trapSum,
    required this.scoreSum,
    required this.basePrice,
    required this.gst,
    required this.cgst,
    required this.total,
    required this.rtpLabel,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onShare,
    required this.onCopy,
    required this.isAddingToCart,
    required this.isBuyingNow,
    required this.canBuy,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final PhoneNumber product;
  final int? literSum;
  final int? trapSum;
  final int? scoreSum;
  final double basePrice;
  final double gst;
  final double cgst;
  final double total;
  final String rtpLabel;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final bool isAddingToCart;
  final bool isBuyingNow;
  final bool canBuy;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  bool get _hasNumerology =>
      literSum != null || trapSum != null || scoreSum != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9D5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.category,
                  style: const TextStyle(
                    color: _orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              InkWell(
                onTap: onShare,
                child: const Row(
                  children: [
                    Icon(Icons.share_outlined, size: 18, color: Color(0xFF4B5563)),
                    SizedBox(width: 4),
                    Text('Share', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFA94D), Color(0xFFE8600A)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatNumber(product.number),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 32,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _greenBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, size: 16, color: _green),
                      SizedBox(width: 6),
                      Text(
                        'Verified Premium',
                        style: TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4B5563),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('Copy Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          if (_hasNumerology) ...[
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 18,
                  decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(width: 8),
                const Text('Numerology Analytics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (literSum != null)
                  Expanded(child: _StatBox(label: 'LITERS SUM', value: literSum!, bg: _blueBg, color: _blue)),
                if (literSum != null) const SizedBox(width: 10),
                if (trapSum != null)
                  Expanded(child: _StatBox(label: 'TRAP SUM', value: trapSum!, bg: _amberBg, color: _amber)),
                if (trapSum != null) const SizedBox(width: 10),
                if (scoreSum != null)
                  Expanded(child: _StatBox(label: 'SCORE', value: scoreSum!, bg: _purpleBg, color: _purple)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _GreenPill(text: rtpLabel)),
              const SizedBox(width: 8),
              const Expanded(child: _GreenPill(text: 'Easy Activation')),
              const SizedBox(width: 8),
              const Expanded(child: _GreenPill(text: 'All India')),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _peachBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Price Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 14),
                _PriceRow(
                  label: 'Price (Without GST)',
                  caption: 'Base price excluding taxes',
                  value: '₹${_formatRupees(basePrice)}.00',
                  valueBold: true,
                ),
                const Divider(height: 28),
                _PriceRow(label: 'GST (18%)', value: '₹${_formatRupees(gst)}.00', valueBold: true),
                const SizedBox(height: 6),
                _PriceSubRow(label: 'CGST (9%)', value: '₹${_formatRupees(cgst)}.00'),
                _PriceSubRow(label: 'SGST (9%)', value: '₹${_formatRupees(cgst)}.00'),
                const Divider(height: 28),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text('(Including GST)', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                        ],
                      ),
                      Text(
                        '₹${_formatRupees(total)}',
                        style: const TextStyle(color: _orange, fontWeight: FontWeight.w900, fontSize: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '* Final payable amount includes all applicable taxes',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canBuy ? onAddToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isAddingToCart
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: onWishlistToggle,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? _orange : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canBuy ? onBuyNow : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkButton,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isBuyingNow
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _TrustItem(icon: Icons.lock_outline, label: 'Secure Payment', color: Color(0xFFCA8A04))),
              Expanded(child: _TrustItem(icon: Icons.check, label: 'Verified Number', color: Colors.black87)),
              Expanded(child: _TrustItem(icon: Icons.bolt, label: 'Easy Activation', color: Color(0xFFCA8A04))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.bg, required this.color});

  final String label;
  final int value;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Text('$value', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _GreenPill extends StatelessWidget {
  const _GreenPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: _greenBg, borderRadius: BorderRadius.circular(30)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, this.caption, required this.value, this.valueBold = false});

  final String label;
  final String? caption;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(caption!, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600, fontSize: valueBold ? 16 : 14),
        ),
      ],
    );
  }
}

class _PriceSubRow extends StatelessWidget {
  const _PriceSubRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text('•  $label', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          ),
          Text(value, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.product});

  final PhoneNumber product;

  @override
  Widget build(BuildContext context) {
    final categoryLower = product.category.toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      color: _peachBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFFFE9D5), borderRadius: BorderRadius.circular(20)),
            child: const Text(
              'PREMIUM QUALITY',
              style: TextStyle(color: _orange, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text('About ${product.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
          const SizedBox(height: 4),
          Text(product.category, style: const TextStyle(color: _orange, fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF374151), fontSize: 15, height: 1.5),
              children: [
                TextSpan(text: 'Looking for a premium $categoryLower mobile number? '),
                TextSpan(text: product.number, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                const TextSpan(text: ' is a stylish and memorable '),
                const TextSpan(
                  text: 'VIP number',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                ),
                const TextSpan(text: ', perfect for personal branding and business use.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            icon: Icons.star,
            iconBg: _orange,
            title: 'Why Choose ${product.number}?',
            body: 'Premium numbers are easy to remember and help create a strong impression. '
                'The unique $categoryLower pattern makes this number stand out instantly.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.auto_fix_high,
            iconBg: _purple,
            title: 'Numerology Significance',
            richBody: TextSpan(
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
              children: [
                const TextSpan(text: 'This number has a liters sum of '),
                TextSpan(text: '${product.numerology?['liters'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                const TextSpan(text: ' and a trap sum of '),
                TextSpan(text: '${product.numerology?['trap'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                const TextSpan(text: ' and a numerology score of '),
                TextSpan(text: '${product.numerology?['score'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                const TextSpan(text: ', often associated with positivity, balance, and good fortune.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.shield_outlined,
            iconBg: const Color(0xFF10B981),
            title: 'Easy Purchase Process',
            richBody: TextSpan(
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
              children: [
                const TextSpan(text: 'Buying '),
                TextSpan(text: product.number, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                const TextSpan(
                  text: ' is quick and secure. Add the number to your cart, complete the payment, '
                      'and get activation support from our team anytime.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.body,
    this.richBody,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String? body;
  final InlineSpan? richBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 8),
          if (richBody != null)
            RichText(text: richBody!)
          else
            Text(body ?? '', style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

/// Section for related-numbers listings. The site backs these with a
/// dedicated "similar numbers" API this app doesn't have wired up, so —
/// same as the live site falls back to when that call fails — this
/// renders the empty/error state rather than fabricating data.
class _RelatedNumbersSection extends StatelessWidget {
  const _RelatedNumbersSection({required this.title, required this.subtitle, this.trailing});

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: _peachBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨ ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              border: Border.all(color: const Color(0xFFFECACA)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text(
                  'Unable to load similar numbers',
                  style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text('Please try again', style: TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(height: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  const _ViewAllCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(height: 8),
            Text('View All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            SizedBox(height: 2),
            Text('Browse complete collection', style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _WhyChooseCategoryCard extends StatelessWidget {
  const _WhyChooseCategoryCard({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final categoryLower = category.toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.15),
              children: [
                const TextSpan(text: 'Why Choose ', style: TextStyle(color: _orange)),
                TextSpan(text: '$category?', style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$category mobile numbers are known for their unique patterns, premium appeal, and '
            'easy memorability. These VIP numbers are ideal for businesses, professionals, and '
            'individuals looking to create a strong and lasting impression.',
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore our collection of $categoryLower numbers with competitive pricing, verified '
            'ownership, and quick activation support. Find a premium number that perfectly matches '
            'your personality or brand identity.',
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _CheckPill(text: 'Easy Activation', bg: Color(0xFFFFE9D5), color: _orange),
              _CheckPill(text: 'Ready to Port', bg: _blueBg, color: _blue),
              _CheckPill(text: 'Verified Numbers', bg: _greenBg, color: _green),
              _CheckPill(text: '24/7 Support', bg: _purpleBg, color: _purple),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckPill extends StatelessWidget {
  const _CheckPill({required this.text, required this.bg, required this.color});

  final String text;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.check, size: 12, color: color),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({
    required this.product,
    required this.rtpLabel,
    required this.total,
    required this.expandedIndex,
    required this.onToggle,
  });

  final PhoneNumber product;
  final String rtpLabel;
  final double total;
  final int? expandedIndex;
  final ValueChanged<int> onToggle;

  List<String> get _answers => [
        'The price of ${product.number} is ₹${_formatRupees(total)} '
            '(including 18% GST). This includes activation and porting support.',
        product.isRTP
            ? 'Yes, this number is Ready to Port (RTP) and can be ported to your '
                'preferred operator immediately after purchase.'
            : product.isCRTP
                ? 'This number is Conditionally Ready to Port. A brief verification '
                    'is required before the porting process can begin.'
                : 'This number requires verification before it can be ported. '
                    'Our team will guide you through the process after purchase.',
        'After completing payment, you\'ll receive a Unique Porting Code (UPC) '
            'via SMS, WhatsApp, and email within 24 hours. Visit your preferred '
            'operator\'s store with ID proof to complete activation.',
        'Yes, absolutely. This number is perfect for business branding, '
            'marketing campaigns, and professional use across all major operators.',
        'In the rare case a number becomes unavailable after payment, you\'ll '
            'receive a full refund or the option to choose an alternative number '
            'of equal value.',
      ];

  static const _questions = [
    'What is the price of {number}?',
    'Is this number ready to port?',
    'How do I get the number after purchase?',
    'Can I use this number for business?',
    'What if the number is not available after payment?',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
              children: [
                TextSpan(text: 'Frequently Asked '),
                TextSpan(text: 'Questions', style: TextStyle(color: _orange)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 48,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_orange, Color(0xFFFFC078)]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < _questions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FaqCard(
                question: _questions[i].replaceAll('{number}', product.number),
                answer: _answers[i],
                expanded: expandedIndex == i,
                onTap: () => onToggle(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                    child: Icon(expanded ? Icons.remove : Icons.add, size: 16, color: Colors.black87),
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 12),
                Text(answer, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplorePatternsSection extends StatelessWidget {
  const _ExplorePatternsSection({required this.onTap});

  final VoidCallback onTap;

  static const _patterns = [
    '786 VIP Numbers',
    'Mirror Numbers',
    'Semi Mirror Numbers',
    'Numbers Without 2, 4, 8',
    'Three Digit Numbers',
    'Two Digit Numbers',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CenteredHeading(title: 'Explore Similar Number Patterns'),
          const SizedBox(height: 4),
          const Text(
            'Explore more number patterns',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 18),
          for (final pattern in _patterns)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: const Color(0xFFFFE9D5), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.chevron_right, color: _orange, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(pattern, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworksSection extends StatelessWidget {
  const _NetworksSection();

  static const _networks = [
    (name: 'airtel', color: Color(0xFFED1C24)),
    (name: 'Jio', color: Color(0xFF0A2885)),
    (name: 'VI', color: Color(0xFFEE0A24)),
    (name: 'BSNL', color: Color(0xFF004C97)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CenteredHeading(title: 'Available on All Networks'),
          const SizedBox(height: 4),
          const Text(
            'Select your preferred operator',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              for (final network in _networks)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    network.name,
                    style: TextStyle(color: network.color, fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CitiesSection extends StatelessWidget {
  const _CitiesSection({required this.category, required this.onTap});

  final String category;
  final VoidCallback onTap;

  static const _cities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Kolkata', 'Pune', 'Ahmedabad'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CenteredHeading(title: 'VIP Numbers Available Across India'),
          const SizedBox(height: 4),
          const Text(
            'Select your city',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final city in _cities)
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFFFF3E8), borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(city, style: const TextStyle(color: _orange, fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: _orange, size: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: _orange,
              side: const BorderSide(color: _orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('View All Locations  →', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('View More $category Numbers  →', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _CenteredHeading extends StatelessWidget {
  const _CenteredHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
    );
  }
}
