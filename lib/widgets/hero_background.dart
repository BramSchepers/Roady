import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Volle-breedte hero-achtergrond voor de web-app (gebruikt in main builder).
class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SvgPicture.asset(
        'assets/illustrations/Background_hero.svg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholderBuilder: (_) => const SizedBox.shrink(),
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
