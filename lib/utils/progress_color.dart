import 'package:flutter/material.dart';

/// Kleuren van de fuel-meter gradient (rood -> oranje -> groen).
const Color _red = Color(0xFFFF5252);
const Color _orange = Color(0xFFFFB74D);
const Color _green = Color(0xFF69F0AE);

/// Geeft een kleur terug op basis van voortgang (0.0 - 1.0).
/// Vloeiende overgang: rood (0%) -> oranje (50%) -> groen (100%).
Color getProgressColor(double progress) {
  final t = progress.clamp(0.0, 1.0);
  if (t <= 0.5) {
    return Color.lerp(_red, _orange, t * 2)!;
  }
  return Color.lerp(_orange, _green, (t - 0.5) * 2)!;
}
