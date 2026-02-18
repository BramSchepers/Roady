import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Breakpoint onder welke we mobiele layout gebruiken.
const double kNarrowViewportMaxWidth = 768.0;

/// Horizontale padding voor onboarding-schermen op web (zelfde breedte als taalkeuze).
/// Contentbreedte = 1000 - 2*143 ≈ 714px (~15% smaller dan bij 80px padding).
const double kOnboardingWebHorizontalPadding = 143.0;

double get onboardingHorizontalPadding =>
    kIsWeb ? kOnboardingWebHorizontalPadding : 24.0;

/// Viewport-aware: op smalle schermen (mobiel of web in mobiele view) altijd 24px.
double onboardingHorizontalPaddingFor(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kNarrowViewportMaxWidth) return 24.0;
  return kIsWeb ? kOnboardingWebHorizontalPadding : 24.0;
}

/// Max content width for onboarding setup screens on web (taal, rijbewijs, regio).
/// Voorkomt dat knoppen/kaarten te breed worden op grote schermen.
const double kOnboardingWebContentMaxWidth = 480.0;

/// Max content width for web pages (oefenvragen, examen, AI, shop, profiel).
/// Gelijk aan theoriepagina voor consistent wit vlak.
const double kWebContentMaxWidth = 1575.0;

/// Max content width for nav bar; aligned with theory page white area.
const double kWebNavContentMaxWidth = 1575.0;

/// Max button width on web (200-300px).
const double kWebButtonMaxWidth = 280.0;
