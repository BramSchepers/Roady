import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/analytics_consent_service.dart';
import '../utils/onboarding_constants.dart';

/// GDPR analytics consent screen (iOS/Android). Shown once before auth when consent not set.
class AnalyticsConsentScreen extends StatelessWidget {
  const AnalyticsConsentScreen({super.key});

  static const _accentBlue = Color(0xFF2563EB);

  static const _strings = <String, Map<String, String>>{
    'nl': {
      'message': 'We gebruiken gegevens om de app te verbeteren en te begrijpen hoe je deze gebruikt. Geen persoonlijke gegevens worden gedeeld met derden.',
      'privacy': 'Privacy',
      'reject': 'Weigeren',
      'accept': 'Accepteren',
    },
    'fr': {
      'message': 'Nous utilisons des données pour améliorer l\'app et comprendre comment vous l\'utilisez. Aucune donnée personnelle n\'est partagée avec des tiers.',
      'privacy': 'Confidentialité',
      'reject': 'Refuser',
      'accept': 'Accepter',
    },
  };

  Map<String, String> _stringsFor(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return _strings[lang] ?? _strings['nl']!;
  }

  Future<void> _onChoice(BuildContext context, bool accepted) async {
    await AnalyticsConsentService.instance.setConsent(accepted);
    if (!context.mounted) return;
    final query = GoRouterState.of(context).uri.query;
    context.go(query.isNotEmpty ? '/auth?$query' : '/auth');
  }

  @override
  Widget build(BuildContext context) {
    final t = _stringsFor(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.webp',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: onboardingHorizontalPaddingFor(context),
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 56,
                        color: _accentBlue.withOpacity(0.8),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t['message']!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black87,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _onChoice(context, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[800],
                                side: BorderSide(color: Colors.grey[400]!),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(t['reject']!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _onChoice(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: _accentBlue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(t['accept']!),
                            ),
                          ),
                        ],
                      ),
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
