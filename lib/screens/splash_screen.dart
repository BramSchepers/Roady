import 'package:flutter/foundation.dart'; // Nodig voor kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/analytics_consent_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _accentBlue = Color(0xFF2563EB);
  static const _duration = Duration(milliseconds: 2500);
  static const _fadeDuration = Duration(milliseconds: 500);
  static const _splashImageSizeWeb = 320.0;
  static const _splashImageSizeMobile = 280.0;
  static const _firstFrameAsset = 'assets/lottie/1stframe_roady.png';
  static const _animatedWebpAsset = 'assets/lottie/Roady_animated.webp';

  /// Op mobiel: true zodra gebruiker op "Start avontuur" tikt; dan rest uitfaden, mascot wuift, daarna navigeren.
  bool _isPlayingMobileAnimation = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: _fadeDuration,
    );
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    // Alleen op Web automatisch doorsturen
    if (kIsWeb) {
      Future.delayed(_duration, _navigateAway);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigateAway() async {
    if (!mounted) return;
    final state = GoRouterState.of(context);
    final query = state.uri.query;
    final path = query.isNotEmpty ? '/auth?$query' : '/auth';

    // On iOS/Android: show analytics consent once if not yet chosen.
    if (!kIsWeb) {
      final hasChoice = await AnalyticsConsentService.instance.hasConsentChoice();
      if (!hasChoice && mounted) {
        context.go(query.isNotEmpty ? '/analytics-consent?$query' : '/analytics-consent');
        return;
      }
    }

    if (!mounted) return;
    context.go(path);
  }

  Widget _buildWebFallback() {
    return Column(
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
    );
  }

  /// Eerste frame en video in dezelfde bounds (Stack), zodat ze perfect op elkaar uitgelijnd zijn.
  Widget _buildAlignedSplashAnimation(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          // Onderlaag: altijd de eerste frame,zelfde afmetingen
          Image.asset(
            _firstFrameAsset,
            fit: BoxFit.contain,
            width: size,
            height: size,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => _buildWebFallback(),
          ),
          // Bovenlaag: video; tijdens laden transparant (eerste frame blijft zichtbaar), daarna precies erbovenop
          Image.asset(
            _animatedWebpAsset,
            fit: BoxFit.contain,
            width: size,
            height: size,
            alignment: Alignment.center,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null && !wasSynchronouslyLoaded) {
                return const SizedBox.shrink(); // eerste frame (onderlaag) blijft zichtbaar
              }
              return child;
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Op web: animatie-laadscherm (WebP); op mobiel: welkom met logo en knop
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _buildAlignedSplashAnimation(_splashImageSizeWeb),
        ),
      );
    }

    // Mobiel: welkom → logo → mascot → tagline → Start avontuur; bij tap faden rest uit, mascot wuift
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Welkom bij',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/images/logo-roady.png',
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        'Roady',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _accentBlue,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: _isPlayingMobileAnimation
                      ? _buildMascotAnimated()
                      : _buildMascotStatic(),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Jouw snelste weg naar je\ntheorie rijbewijs',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _onMobileStartTapped,
                        style: FilledButton.styleFrom(
                          backgroundColor: _accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start avontuur',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotStatic() {
    return Image.asset(
      _firstFrameAsset,
      width: _splashImageSizeMobile,
      height: _splashImageSizeMobile,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/logo-roady.png',
        height: 120,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMascotAnimated() {
    return SizedBox(
      width: _splashImageSizeMobile,
      height: _splashImageSizeMobile,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Image.asset(
            _firstFrameAsset,
            fit: BoxFit.contain,
            width: _splashImageSizeMobile,
            height: _splashImageSizeMobile,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Image.asset(
            _animatedWebpAsset,
            fit: BoxFit.contain,
            width: _splashImageSizeMobile,
            height: _splashImageSizeMobile,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null && !wasSynchronouslyLoaded) {
                return const SizedBox.shrink();
              }
              return child;
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _onMobileStartTapped() {
    setState(() => _isPlayingMobileAnimation = true);
    _fadeController.forward();
    Future.delayed(_duration, () {
      if (mounted) _navigateAway();
    });
  }
}
