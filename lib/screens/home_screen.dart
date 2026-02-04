import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _heroBg = Color(0xFFe8f0e9);
  static const _accentBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _heroBg,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              color: _heroBg,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header / Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/images/logo-roady.svg',
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text('Roady',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _accentBlue)),
                      ),
                      // Optional: Settings or Profile icon could go here
                      Row(
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.person, color: Colors.black87),
                            onPressed: () => context.push('/profile'),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.logout, color: Colors.black87),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted)
                                context.go('/auth?mode=login');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Fuel Meter Section
                  const FuelMeterCard(),

                  const SizedBox(height: 32),

                  Text(
                    'Verder leren',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Navigation Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _HomeNavCard(
                          title: 'Theorie',
                          icon: Icons.menu_book,
                          color: Colors.blue.shade100,
                          iconColor: _accentBlue,
                          onTap: () => context.go('/dashboard?tab=0'),
                        ),
                        _HomeNavCard(
                          title: 'Examen',
                          icon: Icons.school,
                          color: Colors.orange.shade100,
                          iconColor: Colors.orange.shade800,
                          onTap: () => context.go('/dashboard?tab=1'),
                        ),
                        _HomeNavCard(
                          title: 'AI Coach',
                          icon: Icons.smart_toy,
                          color: Colors.purple.shade100,
                          iconColor: Colors.purple.shade800,
                          onTap: () => context.go('/dashboard?tab=2'),
                        ),
                        _HomeNavCard(
                          title: 'Shop',
                          icon: Icons.shopping_cart,
                          color: Colors.green.shade100,
                          iconColor: Colors.green.shade800,
                          onTap: () => context.go('/dashboard?tab=3'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FuelMeterCard extends StatelessWidget {
  const FuelMeterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Examengereedheid',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Nog niet klaar',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Fuel Meter Visual (Placeholder using LinearProgressIndicator)
          Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.25, // Example progress
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Start', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Klaar!',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Voltooi meer cursussen om je tank te vullen!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HomeNavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _HomeNavCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
