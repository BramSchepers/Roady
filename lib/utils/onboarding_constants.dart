import 'package:flutter/foundation.dart' show kIsWeb;

/// Horizontale padding voor onboarding-schermen op web (zelfde breedte als taalkeuze).
/// Contentbreedte = 1000 - 2*143 ≈ 714px (~15% smaller dan bij 80px padding).
const double kOnboardingWebHorizontalPadding = 143.0;

double get onboardingHorizontalPadding =>
    kIsWeb ? kOnboardingWebHorizontalPadding : 24.0;
