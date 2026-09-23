import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/authenticated_client.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/route_observer.dart';
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/utils/theme.dart';
import 'package:numberwale/src/address/presentation/bloc/address_bloc.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/authentication/data/datasources/auth_local_data_source.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/home/presentation/bloc/home_bloc.dart';
import 'package:numberwale/src/profile/presentation/bloc/profile_bloc.dart';
import 'package:numberwale/src/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:provider/provider.dart';

import 'core/common/user_provider.dart';

final _navigatorKey = GlobalKey<NavigatorState>();
final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await di.init();

  // Redirect to login on any 401 response (session expired mid-use).
  // Only fires once a token refresh has already been tried and failed —
  // the session is genuinely gone at this point, not merely expired.
  di.sl<AuthenticatedClient>().onUnauthorized = () async {
    await di.sl<AuthLocalDataSource>().clearCache();
    di.sl<WishlistBloc>().add(const ClearWishlistCacheEvent());
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (route) => false,
    );
  };

  runApp(const NumberwaleApp());
}

class NumberwaleApp extends StatelessWidget {
  const NumberwaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<AuthenticationBloc>()),
          BlocProvider(create: (_) => di.sl<HomeBloc>()),
          BlocProvider(create: (_) => di.sl<AppNavigationCubit>()),
          BlocProvider(create: (_) => di.sl<CartBloc>()),
          BlocProvider(create: (_) => di.sl<ProfileBloc>()),
          BlocProvider(create: (_) => di.sl<AddressBloc>()),
          BlocProvider(create: (_) => di.sl<WishlistBloc>()),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is SignedOut) {
                  // Drop the previous account's saved numbers before the next
                  // sign-in repopulates them.
                  context
                      .read<WishlistBloc>()
                      .add(const ClearWishlistCacheEvent());
                  _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    Routes.login,
                    (route) => false,
                  );
                }
              },
            ),
            // The cart lives app-wide and its buttons are scattered across
            // every product list, so confirmation and errors are reported
            // here once rather than in each screen.
            BlocListener<CartBloc, CartState>(
              listener: _onCartStateChanged,
            ),
            BlocListener<WishlistBloc, WishlistState>(
              listenWhen: (previous, current) =>
                  previous.message != current.message &&
                  current.message != null,
              listener: (context, state) {
                _scaffoldMessengerKey.currentState
                  ?..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(state.message!),
                    duration: const Duration(seconds: 2),
                  ));
              },
            ),
          ],
          child: MaterialApp(
            title: 'Numberwale',
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,
            scaffoldMessengerKey: _scaffoldMessengerKey,
            navigatorObservers: [routeObserver],

            // Theme configuration
            theme: AppTheme().light(),
            darkTheme: AppTheme().dark(),
            themeMode: ThemeMode.light,

            // Routing
            initialRoute: Routes.splash,
            routes: Routes.routes,
            onGenerateRoute: Routes.generateRoute,
          ),
        ),
      ),
    );
  }
}

/// Reports the outcome of a cart mutation from anywhere in the app, and
/// carries "Buy Now" through to the cart once the server has the item.
void _onCartStateChanged(BuildContext context, CartState state) {
  final messenger = _scaffoldMessengerKey.currentState;

  if (state is ItemAddedToCart) {
    if (state.buyNow) {
      _navigatorKey.currentState?.pushNamed(Routes.cart);
      return;
    }
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Text('Added to cart'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => _navigatorKey.currentState?.pushNamed(Routes.cart),
        ),
      ));
    return;
  }

  if (state is CartError) {
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(state.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
  }
}
