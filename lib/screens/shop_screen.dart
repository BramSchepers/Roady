import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/subscription_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Shop',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kies jouw plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Upgrade voor meer mogelijkheden',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            SubscriptionCard(
              title: 'Basic',
              price: '€0 / maand',
              features: const [
                'Alles offline beschikbaar',
                'Geen reclame',
                'Beperkte oefeningen',
              ],
              color: Colors.blue.shade50,
              textColor: Colors.blue.shade900,
              isCurrent: true, // Assuming default is free for now
            ),
            const SizedBox(height: 16),
            SubscriptionCard(
              title: 'Pro',
              price: '€4.99 / maand',
              features: const [
                'Onbeperkte examens (meer dan 1000 vragen)',
                'Alle oefeningen',
              ],
              color: Colors.orange.shade50,
              textColor: Colors.orange.shade900,
              isCurrent: false,
              isPopular: true,
            ),
            const SizedBox(height: 16),
            SubscriptionCard(
              title: 'Premium AI',
              price: '€9.99 / maand',
              features: const [
                'Alles in Pro',
                'AI Coach ondersteuning',
                'Persoonlijke leerroute'
              ],
              color: Colors.purple.shade50,
              textColor: Colors.purple.shade900,
              isCurrent: false,
              isComingSoon: true,
            ),
            // Add some bottom padding for scrolling
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
