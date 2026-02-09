import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/widgets/category_section.dart';
import 'package:numberwale/core/widgets/featured_numbers_section.dart';
import 'package:numberwale/core/widgets/number_search_bar.dart';
import 'package:numberwale/core/widgets/promotional_banner.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';

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

  // Mock data for promotional banners
  List<PromotionalBanner> _getPromotionalBanners(BuildContext context) {
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
        subtitle: 'Get expert advice on lucky numbers',
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

  // Mock data for categories
  List<CategoryItem> _getCategories(BuildContext context) {
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

  // Mock data for featured numbers
  List<FeaturedNumber> _getFeaturedNumbers(BuildContext context) {
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

  // Mock data for latest additions
  List<FeaturedNumber> _getLatestNumbers(BuildContext context) {
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
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
          await Future.delayed(const Duration(seconds: 1));
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
                    banners: _getPromotionalBanners(context),
                  ),
                  const SizedBox(height: 32),

                  // Browse by Category
                  CategorySection(
                    title: 'Browse by Category',
                    subtitle: 'Find numbers that match your preference',
                    categories: _getCategories(context),
                    onSeeAllTap: () {
                      context.read<AppNavigationCubit>().selectTab(1);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Featured VIP Numbers
                  FeaturedNumbersSection(
                    title: 'Featured VIP Numbers',
                    subtitle: 'Handpicked premium selections',
                    numbers: _getFeaturedNumbers(context),
                    onSeeAllTap: () {
                      context.read<AppNavigationCubit>().selectTab(1);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Latest Additions
                  FeaturedNumbersSection(
                    title: 'Latest Additions',
                    subtitle: 'Fresh numbers just added',
                    numbers: _getLatestNumbers(context),
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
                      subtitle: 'We can help you find or create the perfect number',
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
