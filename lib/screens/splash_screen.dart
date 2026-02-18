import 'package:flutter/foundation.dart'; // Nodig voor kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _accentBlue = Color(0xFF2563EB);
  static const _duration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    // Alleen op Web automatisch doorsturen
    if (kIsWeb) {
      Future.delayed(_duration, _navigateAway);
    }
  }

  void _navigateAway() {
    if (!mounted) return;
    final state = GoRouterState.of(context);
    final query = state.uri.query;
    if (query.isNotEmpty) {
      context.go('/auth?$query');
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Op web: animatie-laadscherm (WebP); op mobiel: welkom met logo en knop
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            'assets/lottie/Roady_animated.webp',
            fit: BoxFit.contain,
            width: 320,
            height: 320,
            errorBuilder: (_, __, ___) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo-roady.png',
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 24),
                CircularProgressIndicator(color: _accentBlue),
              ],
            ),
          ),
        ),
      );
    }

    // Mobiel: welkom met logo en knop
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Welkom bij',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/logo-roady.png',
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                'Jouw snelste weg naar je\ntheorie rijbewijs',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/auth'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start mijn avontuur!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
