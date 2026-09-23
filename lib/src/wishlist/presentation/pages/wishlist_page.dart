import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/fancy_number_spans.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/core/widgets/premium_number_card.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
import 'package:numberwale/src/wishlist/domain/entities/wishlist_item.dart';
import 'package:numberwale/src/wishlist/presentation/bloc/wishlist_bloc.dart';

const _orange = Color(0xFFFF8401);
const _navy = Color(0xFF1A1A2E);
const _cardBorder = kPremiumCardBorder;

/// Everything the customer has hearted — single numbers and Corporate Elite
/// Packs alike.
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    // WishlistBloc is app-wide, so it may be sitting on another screen's
    // state — always ask for a fresh list when this page opens.
    context.read<WishlistBloc>().add(const LoadWishlistEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: BlocConsumer<WishlistBloc, WishlistState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) {
          if (state.status != WishlistStatus.failure) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.items.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'No Saved Numbers Yet',
              message: 'Tap the heart on any number to keep it here for later.',
              actionLabel: 'Explore Numbers',
              onAction: () {
                Navigator.pop(context);
                context
                    .read<AppNavigationCubit>()
                    .selectTab(AppNavigationCubit.exploreTab);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WishlistBloc>().add(const LoadWishlistEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return item.isPack
                    ? _PackTile(item: item)
                    : _NumberTile(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

String _formatRupees(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '₹$buffer';
}

/// Numbers priced above ₹5 lakh (incl. GST) are enquiry-only, matching the
/// rest of the app.
bool _isEnquiryOnly(double price) => price * 1.18 > 500000;

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    final number = item.numbers.first;
    final enquiryOnly = _isEnquiryOnly(number.discountedPrice);

    return PremiumNumberCard(
      phoneNumber: number.number,
      price: number.discountedPrice,
      category: number.category,
      numerology: number.numerology,
      onTap: () => Navigator.pushNamed(
        context,
        Routes.productDetail,
        arguments: number.number,
      ),
      trailing: PremiumCardBadge(
        icon: Icons.favorite,
        iconColor: _orange,
        tooltip: 'Remove from wishlist',
        onTap: () => context.read<WishlistBloc>().add(ToggleWishlistEvent(
              itemId: item.id,
              type: item.type,
              packSize: item.packSize,
            )),
      ),
      actions: SizedBox(
        width: double.infinity,
        height: 44,
        child: enquiryOnly
            ? _EnquireButton(number: number.number)
            : _AddToCartButton(number: number),
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    return _WishlistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: _orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Corporate Elite Pack'
                  '${item.packValue == null ? '' : ' · ${item.packValue}'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _RemoveButton(item: item),
            ],
          ),
          const SizedBox(height: 10),
          for (final number in item.numbers)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: _NumberText(number: number.number, size: 15)),
                  Text(
                    _formatRupees(number.discountedPrice),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 20),
          Row(
            children: [
              Text(
                '${item.numbers.length} Numbers',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Text(
                _formatRupees(item.totalPrice),
                style: const TextStyle(
                  fontSize: 18,
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

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder, width: 1.5),
      ),
      child: child,
    );
  }
}

class _NumberText extends StatelessWidget {
  const _NumberText({required this.number, this.size = 20});

  final String number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: buildFancyNumberSpans(
          number,
          plainStyle: TextStyle(
            color: _navy,
            fontWeight: FontWeight.w800,
            fontSize: size,
          ),
          highlightStyle: TextStyle(
            color: _orange,
            fontWeight: FontWeight.w800,
            fontSize: size,
          ),
        ),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Remove from wishlist',
      icon: const Icon(Icons.favorite, color: _orange),
      onPressed: () => context.read<WishlistBloc>().add(ToggleWishlistEvent(
            itemId: item.id,
            type: item.type,
            packSize: item.packSize,
          )),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({required this.number});

  final PhoneNumber number;

  @override
  Widget build(BuildContext context) {
    final productId = number.id;
    return OutlinedButton.icon(
      onPressed: productId == null
          ? null
          : () {
              context
                  .read<CartBloc>()
                  .add(AddToCartEvent(productId: productId));
            },
      icon: const Icon(Icons.add_shopping_cart, size: 16),
      label: const Text('Add to Cart'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _orange,
        side: const BorderSide(color: _orange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}

class _EnquireButton extends StatelessWidget {
  const _EnquireButton({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(
        context,
        Routes.customRequest,
        arguments: number,
      ),
      icon: const Icon(Icons.phone, size: 16),
      label: const Text('Enquire Now'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D3748),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
