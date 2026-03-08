import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:go_router/go_router.dart';

import 'auth/auth_state.dart';
import 'firebase_options.dart';
import 'debug_log.dart';
import 'repositories/quiz_repository.dart';
import 'services/analytics_consent_service.dart';
import 'repositories/theory_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/download_app_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/revenuecat_service.dart';
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
import 'screens/analytics_consent_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';

Page<void> _slideWithBouncePage(GoRouterState state, Widget child) {
  // Web: geen slide, alleen een korte fade-in van de inhoud (tekst, icoontjes).
  if (kIsWeb) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }
  // Mobiel: slide met bounce zoals voorheen.
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

  // Firebase only supports Web, Android, iOS. On Windows/macOS/Linux desktop the channel has no handler.
  final isSupportedPlatform = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (!isSupportedPlatform) {
    throw UnsupportedError(
      'Firebase is not supported on this platform. Run the app on Android, iOS, or Web (Chrome).',
    );
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on PlatformException catch (e) {
    if (e.code == 'channel-error') {
      throw UnsupportedError(
        'Firebase could not connect. Run on Android, iOS, or Web (Chrome). '
        'If on Web, ensure you use Chrome and that Firebase scripts load in web/index.html.',
      );
    }
    rethrow;
  }

  // Analytics: disabled by default; enable only after user consent (iOS/Android). Web uses cookie banner.
  if (!kIsWeb) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    await AnalyticsConsentService.instance.applyStoredConsent();
  }

  // Enable Firestore offline persistence on web only (mobile has it by default).
  if (kIsWeb) {
    FirebaseFirestore.instance.enablePersistence().catchError((_) {});
  }

  // Seed initial quiz questions if needed
  await QuizRepository.instance.seedInitialData();

  // Sync lessen en vragen van server (web + mobiel), niet blokkerend
  TheoryRepository.instance.refreshChaptersFromServer();

  final authState = AuthState();

  // Initialize RevenueCat on supported platforms (iOS/Android); sync user on auth changes
  if (RevenueCatService.isSupported) {
    await RevenueCatService.instance.initialize(appUserId: authState.user?.uid);
    authState.addListener(() => _syncRevenueCatUser(authState));
  }

  runApp(RoadyApp(authState: authState));
}

Future<void> _syncRevenueCatUser(AuthState authState) async {
  if (!RevenueCatService.isSupported) return;
  final uid = authState.user?.uid;
  if (uid != null) {
    await RevenueCatService.instance.logIn(uid);
  } else {
    await RevenueCatService.instance.logOut();
  }
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

        // On web: skip offline-download (alleen relevant voor native app)
        if (kIsWeb && path == '/offline-download') return '/home';

        // On web: redirect echte mobiele browsers naar download-app (geen redirect op viewportbreedte)
        if (kIsWeb) {
          if (path != '/download-app' && isMobileUserAgent()) return '/download-app';
          // Stuur desktop/niet-mobiel weer naar home als ze op /download-app zitten (na resize/refresh)
          if (path == '/download-app' && !isMobileUserAgent()) return '/home';
        }

        final isLoggedIn = authState.isLoggedIn;

        if (path == '/splash') return null;

        if (!isLoggedIn) {
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
        }

        // Gast (anonymous): geen toegang tot quiz en exam-routes; wel tot home, dashboard, shop, profile
        if (authState.isAnonymous) {
          if (path == '/quiz' || path == '/exam-history' || path.startsWith('/exam-review')) {
            return '/auth?reason=register';
          }
        }
        // Ingelogde user op /auth mag blijven als die bewust "terug" deed (back-knop), of als gast (account maken)
        if (path == '/auth' && state.uri.queryParameters['back'] == '1') {
          return null;
        }
        if (path == '/auth' && authState.isAnonymous) {
          // #region agent log
          writeDebugLog('main.dart:redirect', 'auth anonymous stay', {'path': path, 'isAnonymous': true}, 'H4');
          // #endregion
          return null;
        }
        if (path == '/auth' || path == '/') {
          // #region agent log
          writeDebugLog('main.dart:redirect', 'redirect to start', {'path': path}, 'H3');
          // #endregion
          return '/start';
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
          path: '/analytics-consent',
          pageBuilder: (context, state) =>
              _simplePage(state, const AnalyticsConsentScreen()),
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
            final reasonRegister = state.uri.queryParameters['reason'] == 'register';
            return _simplePage(
              state,
              AuthScreen(
                initialSignUp: isSignUp,
                showRegisterPrompt: reasonRegister,
              ),
            );
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
            List<String>? savedQuestionIds;
            if (extra is Map) {
              mode = extra['mode'] as QuizMode? ?? QuizMode.random;
              ttsEnabled = extra['ttsEnabled'] as bool? ?? true;
              final raw = extra['savedQuestionIds'];
              if (raw is List) {
                savedQuestionIds = raw.map((e) => e.toString()).toList();
              }
            } else if (extra is QuizMode) {
              mode = extra;
            }
            return _slideWithBouncePage(
              state,
              QuizScreen(
                mode: mode,
                ttsEnabled: ttsEnabled,
                savedQuestionIds: savedQuestionIds,
              ),
            );
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
