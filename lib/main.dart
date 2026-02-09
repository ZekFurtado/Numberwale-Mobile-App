import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/core/utils/theme.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:provider/provider.dart';

import 'core/common/user_provider.dart';

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
          // Authentication Bloc
          BlocProvider(
            create: (_) => di.sl<AuthenticationBloc>(),
          ),
        ],
        child: MaterialApp(
          title: 'Numberwale',
          debugShowCheckedModeBanner: false,

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
    );
  }
}
