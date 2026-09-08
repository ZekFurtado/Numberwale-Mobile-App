import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/models/filter_models.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/category_section.dart';
import 'package:numberwale/core/widgets/deal_of_the_day_section.dart';
import 'package:numberwale/core/widgets/filter_bottom_sheet.dart';
import 'package:numberwale/core/widgets/image_banner_carousel.dart';
import 'package:numberwale/core/widgets/number_search_bar.dart';
import 'package:numberwale/core/widgets/vip_numbers_section.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/corporate_pack/presentation/widgets/corporate_elite_pack_section.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';
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
    final List<VipNumber> newlyAddedNumbers;
    final List<VipNumber> premiumNumbers;
    final List<PhoneNumber> dealOfTheDayNumbers;

    if (state is HomeDataLoaded) {
      dealOfTheDayNumbers = state.dealOfTheDayNumbers;
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

      premiumNumbers = state.premiumNumbers.map((pn) {
        return VipNumber(
          phoneNumber: pn.number,
          price: pn.price,
          category: pn.category,
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
        return VipNumber(
          phoneNumber: pn.number,
          price: pn.price,
          category: pn.category,
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
      premiumNumbers = [];
      newlyAddedNumbers = [];
      dealOfTheDayNumbers = [];
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
                    VipNumbersSection(
                      title: 'Newly Added VIP Numbers',
                      subtitle: "Fresh numbers uploaded in the last 7 days. "
                          "Grab them before they're gone!",
                      badgeLabel: 'New',
                      badgeIcon: Icons.auto_awesome,
                      numbers: newlyAddedNumbers,
                      onSeeAllTap: () {
                        Navigator.pushNamed(
                            context, Routes.newlyAddedVipNumbers);
                      },
                    ),
                  if (newlyAddedNumbers.isNotEmpty) const SizedBox(height: 32),

                  // Deal of the Day
                  if (dealOfTheDayNumbers.isNotEmpty) ...[
                    DealOfTheDaySection(
                      numbers: dealOfTheDayNumbers,
                      onClaim: (pn) => Navigator.pushNamed(
                        context,
                        Routes.productDetail,
                        arguments: pn.number,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Corporate Elite Pack (Jodi)
                  const CorporateElitePackSection(),
                  const SizedBox(height: 32),

                  // Premium Numbers
                  if (premiumNumbers.isNotEmpty)
                    VipNumbersSection(
                      title: 'Premium Numbers',
                      subtitle: 'Premium numbers available at best prices. '
                          "Grab them before they're gone!",
                      numbers: premiumNumbers,
                      onSeeAllTap: () {
                        context.read<AppNavigationCubit>().selectTab(1);
                      },
                    ),
                  if (premiumNumbers.isNotEmpty) const SizedBox(height: 32),

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

  static const _navy = Color(0xFF1A1A2E);
  static const _logoOrange = Color(0xFFFF6A1F);
  static const _tagline = Color(0xFF9A9A9A);
  static const _dividerColor = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 20),
            const _DrawerLogo(),
            const SizedBox(height: 16),
            const Divider(height: 1, color: _dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) {
                  final isAuthenticated = state is Authenticated;
                  return _AuthButton(
                    label: isAuthenticated ? 'My Account' : 'Sign In',
                    icon:
                        isAuthenticated ? Icons.person : Icons.person_outline,
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.pop(context);
                      if (isAuthenticated) {
                        context.read<AppNavigationCubit>().selectTab(3);
                      } else {
                        Navigator.pushNamed(context, Routes.login);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 1, color: _dividerColor),
            _DrawerNavItem(
              label: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerNavItem(
              label: 'Premium Numbers',
              onTap: () {
                Navigator.pop(context);
                context.read<AppNavigationCubit>().selectTab(1);
              },
            ),
            _DrawerNavItem(
              label: 'Offer Zone',
              onTap: () {
                Navigator.pop(context);
                context.read<AppNavigationCubit>().selectTab(2);
              },
            ),
            _DrawerNavItem(
              label: '5-Min Activation No.',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.fiveMinActivationNumbers);
              },
            ),
            _DrawerNavItem(
              label: 'Corporate Elite Pack',
              highlighted: true,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerNavItem(
              label: 'Numerology',
              trailing: const _NewBadge(),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.numerology);
              },
            ),
            _DrawerNavItem(
              label: 'Contact Us',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.contactUs);
              },
            ),
            const Divider(height: 1, color: _dividerColor),
            _ProductsSection(
              onItemTap: () => Navigator.pop(context),
            ),
            const Divider(height: 1, color: _dividerColor),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined, color: _navy),
              title: const Text(
                'Cart',
                style: TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.cart);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerLogo extends StatelessWidget {
  const _DrawerLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Number',
                style: TextStyle(
                  color: _AppDrawer._navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              TextSpan(
                text: 'Wale',
                style: TextStyle(
                  color: _AppDrawer._logoOrange,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 90,
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_AppDrawer._logoOrange, Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Because Number Matters',
          style: TextStyle(
            color: _AppDrawer._tagline,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.label,
    required this.onTap,
    this.highlighted = false,
    this.trailing,
  });

  final String label;
  final VoidCallback onTap;
  final bool highlighted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: highlighted
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 2)
            : EdgeInsets.zero,
        padding: EdgeInsets.symmetric(
          horizontal: highlighted ? 12 : 20,
          vertical: 14,
        ),
        decoration: highlighted
            ? BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: highlighted
                      ? theme.colorScheme.primary
                      : _AppDrawer._navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _AppDrawer._logoOrange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// The "Products" expandable section (Smart IVR, SMS Solutions, WhatsApp
/// API). These sub-pages aren't built yet, so [onItemTap] only closes the
/// drawer for now.
class _ProductsSection extends StatefulWidget {
  const _ProductsSection({required this.onItemTap});

  final VoidCallback onItemTap;

  @override
  State<_ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<_ProductsSection> {
  bool _expanded = true;

  static const _items = ['Smart IVR', 'SMS Solutions', 'Whatsapp API'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Products',
                    style: TextStyle(
                      color: _AppDrawer._navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _AppDrawer._navy,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ..._items.map(
            (item) => InkWell(
              onTap: widget.onItemTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 20, 12),
                child: Text(
                  item.toUpperCase(),
                  style: const TextStyle(
                    color: _AppDrawer._navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
