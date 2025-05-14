import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotify_only/providers/auth_provider.dart';
import 'package:spotify_only/screens/home_screen.dart';
import 'package:spotify_only/screens/login_screen.dart';
import 'package:spotify_only/screens/splash_screen.dart';
import 'package:spotify_only/screens/account_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter getRouter(BuildContext context) {
    final authProvider = Provider.of<SpotifyAuthProvider>(context, listen: false);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,

      // REDIRECT UNTUK LOGIN/LOGOUT
      redirect: (context, state) {
        final isLoggingIn = state.matchedLocation == '/login';
        final isLoggedIn = authProvider.isAuthenticated;

        // Saat splash
        if (state.matchedLocation == '/') return null;

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        } else if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },

      refreshListenable: authProvider,

      routes: [
        /// Splash screen
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),

        /// Login screen
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        /// Shell untuk layout HomeScreen (Scaffold + BottomNav)
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => HomeScreen(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeContent(),
            ),
            // GoRoute(
            //   path: '/library',
            //   builder: (context, state) => const LibraryContent(),
            // ),
            // GoRoute(
            //   path: '/search',
            //   builder: (context, state) => const SearchContent(),
            // ),
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],

      // Jika route tidak ditemukan
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Route not found: ${state.uri.path}'),
        ),
      ),
    );
  }
}
