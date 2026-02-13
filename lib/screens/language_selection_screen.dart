import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../auth/user_language_repository.dart';
import '../utils/onboarding_constants.dart';
import '../widgets/onboarding_page_indicator.dart';

/// CDN-URLs voor vlagafbeeldingen (geen emojis - Windows Chrome ondersteunt die niet goed).
const _flagBaseUrl = 'https://flagcdn.com/w80';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key, this.backNavigation = false});

  /// True als de gebruiker via de terug-knop hier kwam (niet doorsturen naar volgende stap).
  final bool backNavigation;

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const _heroBg = Color(0xFFe8f0e9);
  static const _accentBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndNavigate());
  }

  Future<void> _checkAndNavigate() async {
    if (!mounted) return;
    if (widget.backNavigation) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }
    final language =
        await UserLanguageRepository.instance.getLanguageOrFetch(user.uid);
    if (!mounted) return;
    if (language != null && language.isNotEmpty) {
      context.go('/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (!kIsWeb)
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
                horizontal: onboardingHorizontalPadding,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/auth?back=1'),
                      color: _accentBlue,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      'assets/images/logo-roady.png',
                      height: kIsWeb ? 34 : 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('Roady',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _accentBlue)),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Kies je taal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: kIsWeb ? 22 : null,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _LanguageOptionCard(
                    title: 'Nederlands',
                    subtitle: 'Dutch',
                    icon: Icons.language,
                    flagImageUrl: '$_flagBaseUrl/nl.png',
                    isActive: true,
                    onTap: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;
                      await UserLanguageRepository.instance
                          .setLanguage(uid, 'nl');
                      if (!context.mounted) return;
                      final nextRoute = await UserLanguageRepository.instance
                          .getNextOnboardingRoute(uid);
                      if (context.mounted) context.go(nextRoute);
                    },
                  ),
                  const SizedBox(height: 16),
                  _LanguageOptionCard(
                    title: 'Français',
                    subtitle: 'Frans',
                    icon: Icons.language,
                    flagImageUrl: '$_flagBaseUrl/fr.png',
                    isActive: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _LanguageOptionCard(
                    title: 'English',
                    subtitle: 'Engels',
                    icon: Icons.language,
                    flagImageUrl: '$_flagBaseUrl/gb.png',
                    isActive: false,
                    onTap: () {},
                  ),
                  const Spacer(),
                  const Center(
                    child: OnboardingPageIndicator(
                      currentIndex: 0,
                      totalSteps: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            'Frans en Engels komen binnenkort beschikbaar!',
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
        ],
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? flagImageUrl;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.flagImageUrl,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF2563EB);
    final compact = kIsWeb; // ~15% smaller op web
    final padding = compact ? 17.0 : 20.0;
    final iconSize = compact ? 24.0 : 28.0;
    final titleFont = compact ? 14.0 : 16.0;
    final subtitleFont = compact ? 12.0 : 14.0;
    final arrowSize = compact ? 17.0 : 20.0;

    return Material(
      color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      elevation: isActive ? 2 : 0,
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 10 : 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? accentColor.withOpacity(0.1)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: flagImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: flagImageUrl!,
                          width: iconSize,
                          height: iconSize,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: iconSize,
                            height: iconSize,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: iconSize / 2,
                              height: iconSize / 2,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isActive ? accentColor : Colors.grey[400],
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            icon,
                            color: isActive ? accentColor : Colors.grey[400],
                            size: iconSize,
                          ),
                        ),
                      )
                    : Icon(
                        icon,
                        color: isActive ? accentColor : Colors.grey[400],
                        size: iconSize,
                      ),
              ),
              SizedBox(width: compact ? 14 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFont,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleFont,
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
                  size: arrowSize,
                )
              else
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 3 : 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Coming soon',
                    style: TextStyle(
                      fontSize: compact ? 9 : 10,
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
