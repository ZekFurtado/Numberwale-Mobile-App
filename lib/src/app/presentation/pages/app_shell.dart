import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/widgets/app_bottom_navigation.dart';
import 'package:numberwale/core/widgets/numberwale_app_bar.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/account/presentation/pages/account_page.dart';
import 'package:numberwale/src/app/presentation/pages/placeholders/customize_placeholder.dart';
import 'package:numberwale/src/app/presentation/pages/placeholders/offer_zone_placeholder.dart';
import 'package:numberwale/src/explore/presentation/pages/explore_numbers_page.dart';
// Import pages
import 'package:numberwale/src/home/presentation/pages/home_page.dart';
import 'package:numberwale/src/home/presentation/bloc/home_bloc.dart';
import 'package:numberwale/src/products/presentation/bloc/product_bloc.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AppNavigationCubit>()),
        BlocProvider(
            create: (_) =>
                di.sl<HomeBloc>()..add(const LoadHomeDataEvent())),
        BlocProvider(create: (_) => di.sl<ProductBloc>()),
      ],
      child: const _AppShellView(),
    );
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView();

  static final List<Widget> _pages = [
    const HomePage(),
    const ExploreNumbersPage(),
    const OfferZonePlaceholder(),
    const CustomizePlaceholder(),
    const AccountPage(),
  ];

  static final List<String> _titles = [
    'Home',
    'Explore Numbers',
    'Offer Zone',
    'Customize Number',
    'Account',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppNavigationCubit, AppNavigationState>(
      builder: (context, state) {
        return Scaffold(
          // Don't show app bar for home page (index 0) and account page (index 4), they have their own
          appBar: state.selectedIndex == 0 || state.selectedIndex == 4
              ? null
              : NumberwaleAppBar(
                  title: _titles[state.selectedIndex],
                  showSearch:
                      state.selectedIndex == 1, // Show search on Explore page
                ),
          body: IndexedStack(index: state.selectedIndex, children: _pages),
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: state.selectedIndex,
            onTap: (index) {
              context.read<AppNavigationCubit>().selectTab(index);
            },
          ),
        );
      },
    );
  }
}
