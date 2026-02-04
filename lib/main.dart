import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_state.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authState = AuthState();
  runApp(RoadyApp(authState: authState));
}

class RoadyApp extends StatelessWidget {
  const RoadyApp({super.key, required this.authState});

  final AuthState authState;

  static const _heroBg = Color(0xFFe8f0e9);

  @override
  Widget build(BuildContext context) {
    final router = _createRouter(authState);
    return MaterialApp.router(
      title: 'Roady',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: _heroBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF2563EB),
          surface: _heroBg,
          surfaceContainerLowest: _heroBg,
        ),
      ),
      routerConfig: router,
    );
  }

  GoRouter _createRouter(AuthState authState) {
    return GoRouter(
      refreshListenable: authState,
      initialLocation: '/splash',
      redirect: (BuildContext context, GoRouterState state) {
        final isLoggedIn = authState.isLoggedIn;
        final path = state.uri.path;

        if (path == '/splash') return null;

        if (!isLoggedIn) {
          if (path == '/dashboard') return '/auth';
          return null;
        }

        if (path == '/auth' || path == '/') return '/dashboard';
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          redirect: (context, state) {
            final query = state.uri.query;
            return query.isNotEmpty ? '/splash?$query' : '/splash';
          },
        ),
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) {
            final mode = state.uri.queryParameters['mode'];
            final isSignUp = mode != 'login';
            return AuthScreen(initialSignUp: isSignUp);
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardScreen(),
        ),
      ],
    );
  }
}
