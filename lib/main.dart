import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/utils/theme.dart';
import 'package:numberwale/src/address/presentation/bloc/address_bloc.dart';
import 'package:numberwale/src/app/presentation/cubit/app_navigation_cubit.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:numberwale/src/cart/presentation/bloc/cart_bloc.dart';
import 'package:numberwale/src/home/presentation/bloc/home_bloc.dart';
import 'package:numberwale/src/profile/presentation/bloc/profile_bloc.dart';
import 'package:provider/provider.dart';

import 'core/common/user_provider.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await di.init();

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
        ],
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is SignedOut) {
              _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                Routes.login,
                (route) => false,
              );
            }
          },
          child: MaterialApp(
            title: 'Numberwale',
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,

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
