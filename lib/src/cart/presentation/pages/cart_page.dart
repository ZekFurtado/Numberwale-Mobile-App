import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/cart_item_card.dart';
import 'package:numberwale/core/widgets/cart_summary_card.dart';
import 'package:numberwale/core/widgets/empty_state.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CartBloc>()..add(const LoadCartEvent()),
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  void _showClearCartDialog(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is ItemRemovedFromCart) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item removed from cart'),
              duration: Duration(seconds: 2),
            ),
          );
          context.read<CartBloc>().add(const LoadCartEvent());
        } else if (state is CartCleared) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cart cleared')),
          );
          context.read<CartBloc>().add(const LoadCartEvent());
        } else if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CartLoading || state is CartInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cart')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CartError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cart')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () =>
                        context.read<CartBloc>().add(const LoadCartEvent()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CartLoaded) {
          final cart = state.cart;
          final isEmpty = cart.isEmpty;
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              title:
                  Text('Cart${isEmpty ? '' : ' (${cart.items.length})'}'),
              actions: [
                if (!isEmpty)
                  IconButton(
                    onPressed: () => _showClearCartDialog(context),
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Clear cart',
                  ),
              ],
            ),
            body: isEmpty
                ? EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Your Cart is Empty',
                    message:
                        'Add some premium numbers to your cart to get started!',
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
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return CartItemCard(
                              phoneNumber: item.productNumber,
                              price: item.price,
                              operator: '',
                              category: '',
                              discount: null,
                              onRemove: () {
                                if (item.id != null) {
                                  context.read<CartBloc>().add(
                                        RemoveCartItemEvent(
                                            itemId: item.id!),
                                      );
                                }
                              },
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.productDetail,
                                  arguments: item.productNumber,
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
                              color: theme.colorScheme.shadow
                                  .withValues(alpha: 0.1),
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
                                  subtotal: cart.subtotal,
                                  discount: 0,
                                  cgst: cart.cgst,
                                  sgst: cart.sgst,
                                ),

                                const SizedBox(height: 16),

                                // Checkout button
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, Routes.checkout);
                                    },
                                    icon: const Icon(Icons.shopping_bag),
                                    label:
                                        const Text('Proceed to Checkout'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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

        // Fallback for transient states (AddingToCart, ItemRemovedFromCart, CartCleared, etc.)
        return Scaffold(
          appBar: AppBar(title: const Text('Cart')),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
