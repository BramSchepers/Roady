import 'dart:async';

import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

/// In-app laadscherm met Lottie-auto; na korte delay doorsturen naar auth/dashboard.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _heroBg = Color(0xFFe8f0e9);
  static const _duration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    Future.delayed(_duration, _navigateAway);
  }

  void _navigateAway() {
    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _heroBg,
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: DotLottieLoader.fromAsset(
            'assets/lottie/car.lottie',
            frameBuilder: (BuildContext context, DotLottie? dotlottie) {
              if (dotlottie != null && dotlottie.animations.isNotEmpty) {
                return Lottie.memory(
                  dotlottie.animations.values.first,
                  fit: BoxFit.contain,
                  repeat: true,
                );
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error_outline, size: 48),
          ),
        ),
      ),
    );
  }
}
