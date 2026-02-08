import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_state.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/exam_region_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/license_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';

Page<void> _slideWithBouncePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        )),
        child: child,
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authState = AuthState();
  runApp(RoadyApp(authState: authState));
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
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
          surfaceContainerLowest: Colors.white,
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
          if (path == '/home' ||
              path == '/dashboard' ||
              path == '/shop' ||
              path == '/license' ||
              path == '/language' ||
              path == '/region' ||
              path == '/start') {
            return '/auth';
          }
          return null;
        }

        if (path == '/auth' || path == '/') return '/start';
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
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const SplashScreen()),
        ),
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) {
            final mode = state.uri.queryParameters['mode'];
            final isSignUp = mode != 'login';
            return _slideWithBouncePage(
                state, AuthScreen(initialSignUp: isSignUp));
          },
        ),
        GoRoute(
          path: '/language',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const LanguageSelectionScreen()),
        ),
        GoRoute(
          path: '/start',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const StartScreen()),
        ),
        GoRoute(
          path: '/license',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const LicenseSelectionScreen()),
        ),
        GoRoute(
          path: '/region',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const ExamRegionSelectionScreen()),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const HomeScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const ProfileScreen()),
        ),
        GoRoute(
          path: '/shop',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const ShopScreen()),
        ),
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) {
            final tab = state.uri.queryParameters['tab'];
            final initialIndex = tab != null ? int.tryParse(tab) ?? 0 : 0;
            return _slideWithBouncePage(
                state, DashboardScreen(initialIndex: initialIndex));
          },
        ),
      ],
    );
  }
}
