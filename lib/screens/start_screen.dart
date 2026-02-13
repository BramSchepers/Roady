import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../auth/user_language_repository.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  static const _accentBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndNavigate());
  }

  Future<void> _checkAndNavigate() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    final nextRoute =
        await UserLanguageRepository.instance.getNextOnboardingRoute(user.uid);
    if (!mounted) return;
    context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (!kIsWeb)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: SvgPicture.asset(
                  'assets/illustrations/Background_hero.svg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholderBuilder: (_) => const SizedBox.shrink(),
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo-roady.png',
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text('Roady',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _accentBlue)),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: _accentBlue,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bezig met laden...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[900],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
