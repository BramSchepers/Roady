import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_state.dart';
import 'auth/user_language_repository.dart';
import 'firebase_options.dart';
import 'repositories/quiz_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/download_app_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/mobile_web_detector.dart';
import 'screens/exam_region_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/license_selection_screen.dart';
import 'screens/exam_history_screen.dart';
import 'screens/exam_review_screen.dart';
import 'screens/offline_download_screen.dart';
import 'screens/profile_screen.dart';
import 'models/quiz_models.dart';
import 'screens/quiz_screen.dart';
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

/// Eenvoudige pagina zonder stuiter-effect, voor beginschermen (onboarding).
Page<void> _simplePage(GoRouterState state, Widget child) {
  return MaterialPage<void>(key: state.pageKey, child: child);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence on web only (mobile has it by default).
  if (kIsWeb) {
    FirebaseFirestore.instance.enablePersistence().catchError((_) {});
  }

  // Seed initial quiz questions if needed
  await QuizRepository.instance.seedInitialData();

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
      redirect: (BuildContext context, GoRouterState state) async {
        final path = state.uri.path;

        // On web: redirect mobile/narrow viewport to download-app unless opted in
        if (kIsWeb && path != '/download-app') {
          final width = MediaQuery.sizeOf(context).width;
          final looksMobile = isMobileUserAgent() || width < 768;
          if (looksMobile) {
            final optedIn = await DownloadAppScreen.getWebOptedIn();
            if (!optedIn) return '/download-app';
          }
        }

        final isLoggedIn = authState.isLoggedIn;

        // Ingelogde gebruiker: direct naar dashboard/onboarding, geen welkomstscherm
        if (isLoggedIn) {
          final uid = authState.user!.uid;
          // Van splash of auth/start: direct naar de juiste bestemming
          if (path == '/splash' || path == '/auth' || path == '/' || path == '/start') {
            if (path == '/auth' && state.uri.queryParameters['back'] == '1') {
              return null; // Bewust terug naar auth
            }
            return UserLanguageRepository.instance.getNextOnboardingRoute(uid);
          }
          return null;
        }

        // Niet ingelogd: beschermde routes naar auth
        if (path == '/splash') return null;

        if (path == '/home' ||
            path == '/dashboard' ||
            path == '/shop' ||
            path == '/license' ||
            path == '/language' ||
            path == '/region' ||
            path == '/offline-download' ||
            path == '/start' ||
            path == '/quiz' ||
            path == '/exam-history' ||
            path.startsWith('/exam-review')) {
          return '/auth';
        }
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
              _simplePage(state, const SplashScreen()),
        ),
        GoRoute(
          path: '/download-app',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const DownloadAppScreen()),
        ),
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) {
            final mode = state.uri.queryParameters['mode'];
            final isSignUp = mode != 'login';
            return _simplePage(state, AuthScreen(initialSignUp: isSignUp));
          },
        ),
        GoRoute(
          path: '/language',
          pageBuilder: (context, state) => _simplePage(
            state,
            LanguageSelectionScreen(
              backNavigation: state.extra == true,
            ),
          ),
        ),
        GoRoute(
          path: '/start',
          pageBuilder: (context, state) =>
              _simplePage(state, const StartScreen()),
        ),
        GoRoute(
          path: '/license',
          pageBuilder: (context, state) =>
              _simplePage(state, const LicenseSelectionScreen()),
        ),
        GoRoute(
          path: '/region',
          pageBuilder: (context, state) =>
              _simplePage(state, const ExamRegionSelectionScreen()),
        ),
        GoRoute(
          path: '/offline-download',
          pageBuilder: (context, state) =>
              _simplePage(state, const OfflineDownloadScreen()),
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
        GoRoute(
          path: '/quiz',
          pageBuilder: (context, state) {
            final extra = state.extra;
            QuizMode mode = QuizMode.random;
            bool ttsEnabled = true;
            if (extra is Map) {
              mode = extra['mode'] as QuizMode? ?? QuizMode.random;
              ttsEnabled = extra['ttsEnabled'] as bool? ?? true;
            } else if (extra is QuizMode) {
              mode = extra;
            }
            return _slideWithBouncePage(
                state, QuizScreen(mode: mode, ttsEnabled: ttsEnabled));
          },
        ),
        GoRoute(
          path: '/exam-history',
          pageBuilder: (context, state) =>
              _slideWithBouncePage(state, const ExamHistoryScreen()),
        ),
        GoRoute(
          path: '/exam-review/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _slideWithBouncePage(state, ExamReviewScreen(attemptId: id));
          },
        ),
      ],
    );
  }
}
