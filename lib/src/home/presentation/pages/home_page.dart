import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/models/filter_models.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/category_section.dart';
import 'package:numberwale/core/widgets/featured_numbers_section.dart';
import 'package:numberwale/core/widgets/filter_bottom_sheet.dart';
import 'package:numberwale/core/widgets/image_banner_carousel.dart';
import 'package:numberwale/core/widgets/number_search_bar.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/corporate_pack/presentation/widgets/corporate_elite_pack_section.dart';
import 'package:numberwale/src/home/presentation/bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  /// Local banner images shown in the homescreen carousel.
  static const List<String> _bannerAssets = [
    'assets/banners/banner1.png',
    'assets/banners/banner2.png',
    'assets/banners/banner3.jpeg',
    'assets/banners/banner4.gif',
    'assets/banners/banner6.jpeg',
    'assets/banners/banner8.jpeg',
  ];


  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeDataEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        },
      ),
      CategoryItem(
        title: 'Fancy Numbers',
        icon: Icons.auto_awesome,
        color: theme.colorScheme.primary,
        count: 189,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
        },
      ),
      CategoryItem(
        title: 'Lucky Numbers',
        icon: Icons.casino,
        color: theme.colorScheme.tertiary,
        count: 312,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
        },
      ),
      CategoryItem(
        title: 'Special Series',
        icon: Icons.format_list_numbered,
        color: theme.colorScheme.secondary,
        count: 156,
        onTap: () {
          context.read<AppNavigationCubit>().selectTab(1);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is LoadingHomeData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<HomeBloc>()
                          .add(const LoadHomeDataEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    final theme = Theme.of(context);

    final List<CategoryItem> categories;
    final List<FeaturedNumber> discountedNumbers;
    final List<FeaturedNumber> newlyAddedNumbers;

    if (state is HomeDataLoaded) {
      categories = state.categories.isEmpty
          ? _getMockCategories(context).take(4).toList()
          : state.categories.take(4).map((cat) {
              return CategoryItem(
                title: cat.name,
                icon: _categoryIcon(cat.slug),
                color: _parseColor(cat.color, theme.colorScheme.primary),
                count: cat.count,
                onTap: () => context.read<AppNavigationCubit>().selectTab(1),
              );
            }).toList();

      discountedNumbers = state.discountedNumbers.map((pn) {
        return FeaturedNumber(
          phoneNumber: pn.number,
          price: pn.price,
          category: pn.category,
          features: pn.features,
          discount: pn.discount > 0 ? pn.discount.toDouble() : null,
          isFeatured: pn.isFeatured,
          numerology: pn.numerology,
          onTap: () => Navigator.pushNamed(
            context,
            Routes.productDetail,
            arguments: pn.number,
          ),
          onAddToCart: () => context.read<CartBloc>().add(AddToCartEvent(
                productId: pn.id ?? pn.number,
              )),
        );
      }).toList();

      newlyAddedNumbers = state.newlyAddedNumbers.map((pn) {
        return FeaturedNumber(
          phoneNumber: pn.number,
          price: pn.price,
          category: pn.category,
          features: pn.features,
          discount: pn.discount > 0 ? pn.discount.toDouble() : null,
          isFeatured: pn.isFeatured,
          numerology: pn.numerology,
          onTap: () => Navigator.pushNamed(
            context,
            Routes.productDetail,
            arguments: pn.number,
          ),
          onAddToCart: () => context.read<CartBloc>().add(AddToCartEvent(
                productId: pn.id ?? pn.number,
              )),
        );
      }).toList();
    } else {
      categories = _getMockCategories(context).take(4).toList();
      discountedNumbers = [];
      newlyAddedNumbers = [];
    }

    return Scaffold(
      backgroundColor: Color(0xFFfef5ee),
      drawer: const _AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<HomeBloc>()
              .add(const RefreshHomeDataEvent());
        },
        child: CustomScrollView(
          slivers: [
            // App Bar with Search
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              title: Row(
                children: [
                  Icon(
                    Icons.phone_android,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Numberwale',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Navigate to notifications
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: NumberSearchBar(
                    controller: _searchController,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        context
                            .read<AppNavigationCubit>()
                            .selectTabWithSearch(1, value.trim());
                      } else {
                        context.read<AppNavigationCubit>().selectTab(1);
                      }
                    },
                    onFilterTap: () async {
                      final filters = await FilterBottomSheet.show(
                        context,
                        initialFilters: const NumberFilters(),
                      );
                      if (filters != null && context.mounted) {
                        context
                            .read<AppNavigationCubit>()
                            .selectTabWithFilters(1, filters);
                      }
                    },
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Promotional Banners Carousel
                  const ImageBannerCarousel(
                    assetPaths: _bannerAssets,
                  ),
                  const SizedBox(height: 32),

                  // Browse by Category
                  CategorySection(
                    title: 'Browse by Category',
                    subtitle: 'Find numbers that match your preference',
                    categories: categories,
                    onSeeAllTap: () {
                      Navigator.pushNamed(context, Routes.categories);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Newly Added VIP Numbers
                  if (newlyAddedNumbers.isNotEmpty)
                    FeaturedNumbersSection(
                      title: 'Newly Added VIP Numbers',
                      subtitle: 'Fresh numbers added this week',
                      numbers: newlyAddedNumbers,
                      onSeeAllTap: () {
                        Navigator.pushNamed(
                            context, Routes.newlyAddedVipNumbers);
                      },
                    ),
                  if (newlyAddedNumbers.isNotEmpty) const SizedBox(height: 32),

                  // Corporate Elite Pack (Jodi)
                  const CorporateElitePackSection(),
                  const SizedBox(height: 32),

                  // Discounted Numbers
                  if (discountedNumbers.isNotEmpty)
                    FeaturedNumbersSection(
                      title: 'Discounted Numbers',
                      subtitle: 'Special offers and deals',
                      numbers: discountedNumbers,
                      onSeeAllTap: () {
                        context.read<AppNavigationCubit>().selectTab(1);
                      },
                    ),
                  if (discountedNumbers.isNotEmpty) const SizedBox(height: 32),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.phone_android, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Numberwale',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Numerology'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.numerology);
              },
            ),
          ],
        ),
      ),
    );
  }
}
