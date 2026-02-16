import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/category_section.dart';
import 'package:numberwale/core/widgets/featured_numbers_section.dart';
import 'package:numberwale/core/widgets/number_search_bar.dart';
import 'package:numberwale/core/widgets/promotional_banner.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/home/presentation/bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

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

  /// Returns the 3 hardcoded promotional banners used as mock/fallback data.
  List<PromotionalBanner> _getMockPromotionalBanners(BuildContext context) {
    final theme = Theme.of(context);
    return [
      PromotionalBanner(
        title: 'New Year Mega Sale',
        subtitle: 'Get up to 50% off on VIP numbers',
        buttonText: 'Shop Now',
        icon: Icons.celebration,
        backgroundColor: theme.colorScheme.primaryContainer,
        onTap: () {
          // Navigate to offers
        },
      ),
      PromotionalBanner(
        title: 'Free Delivery',
        subtitle: 'On all orders this week',
        buttonText: 'Explore',
        icon: Icons.local_shipping,
        backgroundColor: theme.colorScheme.secondaryContainer,
        textColor: theme.colorScheme.onSecondaryContainer,
        onTap: () {
          // Navigate to all numbers
        },
      ),
      PromotionalBanner(
        title: 'Numerology Consultation',
        subtitle: 'Expert advice on lucky numbers',
        buttonText: 'Book Now',
        icon: Icons.auto_awesome,
        backgroundColor: theme.colorScheme.tertiaryContainer,
        textColor: theme.colorScheme.onTertiaryContainer,
        onTap: () {
          Navigator.pushNamed(context, Routes.numerologyConsultation);
        },
      ),
    ];
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

  /// Returns mock featured numbers used as fallback when the API list is empty.
  List<FeaturedNumber> _getMockFeaturedNumbers(BuildContext context) {
    return [
      FeaturedNumber(
        phoneNumber: '9876543210',
        price: 25000,
        category: 'VIP',
        features: ['Sequential', 'Premium', 'Easy'],
        discount: 10,
        isFeatured: true,
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.productDetail,
            arguments: '9876543210',
          );
        },
        onAddToCart: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart!')),
          );
        },
      ),
      FeaturedNumber(
        phoneNumber: '9999999999',
        price: 50000,
        category: 'Premium VIP',
        features: ['All 9s', 'Unique', 'Lucky'],
        isFeatured: true,
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.productDetail,
            arguments: '9999999999',
          );
        },
        onAddToCart: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart!')),
          );
        },
      ),
      FeaturedNumber(
        phoneNumber: '9876000000',
        price: 15000,
        category: 'Fancy',
        features: ['Pattern', 'Memorable'],
        discount: 15,
        isFeatured: true,
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.productDetail,
            arguments: '9876000000',
          );
        },
        onAddToCart: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart!')),
          );
        },
      ),
    ];
  }

  /// Returns mock latest numbers used as fallback when the API list is empty.
  List<FeaturedNumber> _getMockLatestNumbers(BuildContext context) {
    return [
      FeaturedNumber(
        phoneNumber: '9811111111',
        price: 35000,
        category: 'VIP',
        features: ['Repeating', 'Premium'],
        discount: 5,
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.productDetail,
            arguments: '9811111111',
          );
        },
        onAddToCart: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart!')),
          );
        },
      ),
      FeaturedNumber(
        phoneNumber: '9123456789',
        price: 12000,
        category: 'Sequential',
        features: ['Easy', 'Memorable'],
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.productDetail,
            arguments: '9123456789',
          );
        },
        onAddToCart: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart!')),
          );
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

    // Resolve data from loaded state or fall back to mock data.
    final List<PromotionalBanner> banners;
    final List<CategoryItem> categories;
    final List<FeaturedNumber> featuredNumbers;
    final List<FeaturedNumber> latestNumbers;

    if (state is HomeDataLoaded) {
      // Map API banners → PromotionalBanner widgets
      if (state.banners.isEmpty) {
        banners = _getMockPromotionalBanners(context);
      } else {
        banners = state.banners.map((b) {
          return PromotionalBanner(
            title: b.title,
            subtitle: b.subtitle,
            buttonText: b.buttonText,
            backgroundColor: _parseColor(
                b.backgroundColor, theme.colorScheme.primaryContainer),
            textColor:
                _parseColor(b.textColor, theme.colorScheme.onPrimaryContainer),
            onTap: () {
              if (b.actionUrl != null && b.actionUrl!.isNotEmpty) {
                Navigator.pushNamed(context, b.actionUrl!);
              }
            },
          );
        }).toList();
      }

      // Map API categories → CategoryItem objects
      if (state.categories.isEmpty) {
        categories = _getMockCategories(context);
      } else {
        categories = state.categories.map((cat) {
          return CategoryItem(
            title: cat.name,
            icon: _categoryIcon(cat.slug),
            color: _parseColor(cat.color, theme.colorScheme.primary),
            count: cat.count,
            onTap: () {
              context.read<AppNavigationCubit>().selectTab(1);
            },
          );
        }).toList();
      }

      // Map API featured numbers → FeaturedNumber objects
      if (state.featuredNumbers.isEmpty) {
        featuredNumbers = _getMockFeaturedNumbers(context);
      } else {
        featuredNumbers = state.featuredNumbers.map((pn) {
          return FeaturedNumber(
            phoneNumber: pn.number,
            price: pn.price,
            category: pn.category,
            features: pn.features,
            discount: pn.discount > 0 ? pn.discount.toDouble() : null,
            isFeatured: pn.isFeatured,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.productDetail,
                arguments: pn.number,
              );
            },
            onAddToCart: () {
              context.read<CartBloc>().add(
                    AddToCartEvent(productId: pn.id ?? pn.number),
                  );
            },
          );
        }).toList();
      }

      // Map API latest numbers → FeaturedNumber objects
      if (state.latestNumbers.isEmpty) {
        latestNumbers = _getMockLatestNumbers(context);
      } else {
        latestNumbers = state.latestNumbers.map((pn) {
          return FeaturedNumber(
            phoneNumber: pn.number,
            price: pn.price,
            category: pn.category,
            features: pn.features,
            discount: pn.discount > 0 ? pn.discount.toDouble() : null,
            isFeatured: pn.isFeatured,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.productDetail,
                arguments: pn.number,
              );
            },
            onAddToCart: () {
              context.read<CartBloc>().add(
                    AddToCartEvent(productId: pn.id ?? pn.number),
                  );
            },
          );
        }).toList();
      }
    } else {
      // Initial or refreshing state: show mock data so UI isn't empty
      banners = _getMockPromotionalBanners(context);
      categories = _getMockCategories(context);
      featuredNumbers = _getMockFeaturedNumbers(context);
      latestNumbers = _getMockLatestNumbers(context);
    }

    return Scaffold(
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
                      context.read<AppNavigationCubit>().selectTab(1);
                    },
                    onFilterTap: () {
                      Navigator.pushNamed(context, Routes.advancedSearch);
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
                  PromotionalCarousel(
                    banners: banners,
                  ),
                  const SizedBox(height: 32),

                  // Browse by Category
                  CategorySection(
                    title: 'Browse by Category',
                    subtitle: 'Find numbers that match your preference',
                    categories: categories,
                    onSeeAllTap: () {
                      context.read<AppNavigationCubit>().selectTab(1);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Featured VIP Numbers
                  FeaturedNumbersSection(
                    title: 'Featured VIP Numbers',
                    subtitle: 'Handpicked premium selections',
                    numbers: featuredNumbers,
                    onSeeAllTap: () {
                      context.read<AppNavigationCubit>().selectTab(1);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Latest Additions
                  FeaturedNumbersSection(
                    title: 'Latest Additions',
                    subtitle: 'Fresh numbers just added',
                    numbers: latestNumbers,
                    onSeeAllTap: () {
                      context.read<AppNavigationCubit>().selectTab(1);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Special Services Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PromotionalBanner(
                      title: 'Need a Custom Number?',
                      subtitle:
                          'We can help you find or create the perfect number',
                      buttonText: 'Request Custom Number',
                      icon: Icons.create,
                      backgroundColor: theme.colorScheme.tertiaryContainer,
                      textColor: theme.colorScheme.onTertiaryContainer,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.customRequest);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
