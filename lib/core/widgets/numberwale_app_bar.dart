import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/cart_badge.dart';
import 'package:numberwale/src/products/domain/entities/product_filters.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

class NumberwaleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NumberwaleAppBar({
    required this.title,
    this.showSearch = false,
    this.cartCount = 0,
    super.key,
  });

  final String title;
  final bool showSearch;
  final int cartCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await Navigator.pushNamed<ProductFilters>(
                context,
                Routes.advancedSearch,
              );
              if (result != null && context.mounted) {
                context.read<ProductBloc>().add(ApplyFiltersEvent(filters: result));
              }
            },
            tooltip: 'Search',
          ),
        IconButton(
          icon: CartBadge(
            count: cartCount,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          onPressed: () {
            Navigator.pushNamed(context, Routes.cart);
          },
          tooltip: 'Cart',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
