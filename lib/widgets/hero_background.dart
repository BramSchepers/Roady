import 'package:flutter/material.dart';

/// Volle-breedte hero-achtergrond voor de web-app (gebruikt in main builder).
class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.asset(
        'assets/images/background.webp',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
