import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/widgets/category_section.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/home/presentation/bloc/home_bloc.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  /// Maps a category slug or icon name to a Flutter [IconData].
  IconData _categoryIcon(String? iconName) {
    if (iconName == null) return Icons.phone_android;
    final lower = iconName.toLowerCase();
    if (lower == 'vip' || lower.contains('vip')) return Icons.star;
    if (lower == 'fancy' || lower.contains('fancy')) return Icons.auto_awesome;
    if (lower == 'lucky' || lower.contains('lucky')) return Icons.casino;
    if (lower == 'repeated' || lower == 'repeat') return Icons.repeat;
    if (lower == 'palindrome') return Icons.sync;
    if (lower == 'numerology') return Icons.calculate;
    return Icons.phone_android;
  }

  /// Converts a hex color string (e.g. "#RRGGBB" or "RRGGBB") to a [Color].
  /// Returns [fallback] on any parse error.
  Color _parseColor(String? hexColor, Color fallback) {
    if (hexColor == null || hexColor.isEmpty) return fallback;
    try {
      final hex = hexColor.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {
      // fall through to fallback
    }
    return fallback;
  }

  /// Returns mock category items used as fallback when the API list is empty.
  List<CategoryItem> _getMockCategories(BuildContext context) {
    final theme = Theme.of(context);
    return [
      CategoryItem(
        title: 'VIP Numbers',
        icon: Icons.star,
        color: const Color(0xFFFFD700),
        count: 245,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
      CategoryItem(
        title: 'Fancy Numbers',
        icon: Icons.auto_awesome,
        color: theme.colorScheme.primary,
        count: 189,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
      CategoryItem(
        title: 'Lucky Numbers',
        icon: Icons.casino,
        color: theme.colorScheme.tertiary,
        count: 312,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
      CategoryItem(
        title: 'Special Series',
        icon: Icons.format_list_numbered,
        color: theme.colorScheme.secondary,
        count: 156,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
      CategoryItem(
        title: 'Repeating Numbers',
        icon: Icons.repeat,
        color: Colors.orange,
        count: 98,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
      CategoryItem(
        title: 'Palindrome Numbers',
        icon: Icons.sync,
        color: Colors.purple,
        count: 67,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
      CategoryItem(
        title: 'Sequential Numbers',
        icon: Icons.trending_up,
        color: Colors.green,
        count: 134,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
      CategoryItem(
        title: 'Premium Numbers',
        icon: Icons.diamond,
        color: Colors.blue,
        count: 89,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
          Navigator.pop(context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        elevation: 0,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          List<CategoryItem> categories;

          if (state is HomeDataLoaded && state.categories.isNotEmpty) {
            // Map API categories to CategoryItem objects
            categories = state.categories.map((cat) {
              return CategoryItem(
                title: cat.name,
                icon: _categoryIcon(cat.slug),
                color: _parseColor(cat.color, theme.colorScheme.primary),
                count: cat.count,
                onTap: () {
                  context.read<AppNavigationCubit>().selectTab(1);
                  Navigator.pop(context);
                },
              );
            }).toList();
          } else {
            // Use mock categories as fallback
            categories = _getMockCategories(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const RefreshHomeDataEvent());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                CategorySection(
                  title: 'Browse by Category',
                  subtitle: 'Explore all number categories',
                  categories: categories,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
