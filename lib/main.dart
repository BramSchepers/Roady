import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'auth/auth_state.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authState = AuthState();
  runApp(RoadyApp(authState: authState));

  // Remove splash after first frame so auth redirect can run
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

class RoadyApp extends StatelessWidget {
  const RoadyApp({super.key, required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final router = _createRouter(authState);
    return MaterialApp.router(
      title: 'Roady',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
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
        final plan = state.uri.queryParameters['plan'];

        if (path == '/splash') return null;

        if (!isLoggedIn) {
          if (path == '/dashboard' || path == '/app' || path == '/payment') {
            final query = plan != null ? '?plan=$plan' : '';
            return '/auth$query';
          }
          return null;
        }

        if (path == '/auth' || path == '/') {
          if (plan == 'standard' || plan == 'ai') {
            return '/payment?plan=$plan';
          }
          return '/dashboard';
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/app',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) => const PaymentScreen(),
        ),
      ],
    );
  }
}
