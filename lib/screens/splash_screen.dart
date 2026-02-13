import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/foundation.dart'; // Nodig voor kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _heroBg = Color(0xFFe8f0e9);
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
    // Op Web tonen we alleen de "loading" animatie
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: DotLottieLoader.fromAsset(
              'assets/lottie/car.lottie',
              frameBuilder: (BuildContext context, dotlottie) {
                if (dotlottie != null && dotlottie.animations.isNotEmpty) {
                  return Lottie.memory(
                    dotlottie.animations.values.first,
                    fit: BoxFit.contain,
                    repeat: true,
                  );
                }
                return const SizedBox.shrink();
              },
              errorBuilder: (_, __, ___) => const Icon(Icons.directions_car,
                  size: 48, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Op App (Android/iOS) tonen we het volledige Welkomstscherm
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Achtergrond: wit zodat overflow (grote schermen / scroll) wit is
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: SvgPicture.asset(
                'assets/illustrations/Background_hero.svg',
                fit: BoxFit.cover,
                placeholderBuilder: (_) => const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Welkom tekst
                  Text(
                    'Welkom bij',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Logo
                  Image.asset(
                    'assets/images/logo-roady.png',
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  // Slogan
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
                  // Knop
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        context.go('/auth');
                      },
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
        ],
      ),
    );
  }
}
