import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberwale/core/errors/failures.dart';
import 'package:numberwale/core/services/injection_container.dart' as di;
import 'package:numberwale/core/utils/routes.dart';
import 'package:numberwale/src/authentication/data/datasources/auth_local_data_source.dart';
import 'package:numberwale/src/authentication/domain/usecases/refresh_token.dart';
import 'package:numberwale/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Navigate after splash delay
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Run the minimum display timer and session check concurrently.
    final minDisplay = Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ?? false;
    final cachedUser = prefs.getString('CACHED_USER');

    String nextRoute;

    if (!hasCompletedOnboarding) {
      nextRoute = Routes.onboarding;
    } else if (cachedUser == null) {
      nextRoute = Routes.login;
    } else {
      // Try to refresh the session so a fresh access token/cookie is ready,
      // but only treat it as gone when the server actively rejects the
      // refresh token (401/403) — a real "you're logged out". Any other
      // failure (no internet yet on a cold start, a slow/broken backend,
      // a stray exception) is inconclusive, not proof the session is
      // invalid, so the cached session is kept either way. A genuine
      // mid-session 401 later is still caught by
      // AuthenticatedClient.onUnauthorized (wired in main.dart), which is
      // the same mechanism this used to skip.
      final rejected = await _sessionExplicitlyRejected();
      if (rejected) {
        await di.sl<AuthLocalDataSource>().clearCache();
        nextRoute = Routes.login;
      } else {
        // Hydrate AuthenticationBloc from the cached user so pages that
        // fall back to it (profile summary, cart's profile card) have data
        // immediately instead of sitting on AuthenticationInitial until
        // ProfileBloc's own network call resolves.
        if (mounted) {
          context.read<AuthenticationBloc>().add(const GetUserSessionEvent());
        }
        nextRoute = Routes.appShell;
      }
    }

    await minDisplay;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  /// True only when the server actively rejected the refresh token
  /// (401/403). Never true for network errors or other transient failures.
  Future<bool> _sessionExplicitlyRejected() async {
    try {
      final result = await di.sl<RefreshToken>()();
      return result.fold(
        (failure) =>
            failure is! NetworkFailure &&
            (failure.statusCode == '401' || failure.statusCode == '403'),
        (_) => false,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.phone_android,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // App Name
                Text(
                  'Numberwale',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Premium Phone Numbers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 48),

                // Loading Indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
