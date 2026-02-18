import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../auth/user_language_repository.dart';
import '../utils/onboarding_constants.dart';
import '../widgets/onboarding_page_indicator.dart';

class LicenseSelectionScreen extends StatelessWidget {
  const LicenseSelectionScreen({super.key});

  static const _heroBg = Color(0xFFe8f0e9);
  static const _accentBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: onboardingHorizontalPaddingFor(context),
                vertical: 24.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (kIsWeb &&
                            MediaQuery.sizeOf(context).width >=
                                kNarrowViewportMaxWidth)
                        ? kOnboardingWebContentMaxWidth
                        : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/language', extra: true),
                      color: _accentBlue,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo-roady.png',
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('Roady',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _accentBlue)),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Title
                  Text(
                    'Welk rijbewijswil je halen?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Option B (Active)
                  _LicenseOptionCard(
                    title: 'Rijbewijs B',
                    subtitle: 'Auto',
                    icon: Icons.directions_car_filled,
                    isActive: true,
                    onTap: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;
                      await UserLanguageRepository.instance
                          .setLicenseType(uid, 'B');
                      if (!context.mounted) return;
                      final nextRoute = await UserLanguageRepository.instance
                          .getNextOnboardingRoute(uid);
                      if (context.mounted) context.go(nextRoute);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Other Options (Disabled)
                  _LicenseOptionCard(
                    title: 'Andere rijbewijzen',
                    subtitle: 'Motor, Bromfiets, Vrachtwagen...',
                    icon: Icons.two_wheeler,
                    isActive: false,
                    onTap: () {},
                  ),

                  const Spacer(),
                  const Center(
                    child: OnboardingPageIndicator(
                      currentIndex: 1,
                      totalSteps: kIsWeb ? 3 : 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info Text
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.grey[900]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Wij werken hard om in de toekomst meer types toe te voegen!',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _LicenseOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF2563EB);

    return Material(
      color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      elevation: isActive ? 2 : 0,
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? accentColor.withOpacity(0.1)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isActive ? accentColor : Colors.grey[400],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? Colors.grey[900] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: accentColor,
                  size: 20,
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Binnenkort',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
