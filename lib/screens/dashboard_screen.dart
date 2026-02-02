import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dashboard na inloggen: welkom, "Lessen bekijken", "Abonnement kiezen", uitloggen.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _bg = Color(0xFFF5F7FA);
  static const _grey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final email = user?.email ?? '';
    final welcome = displayName != null && displayName.isNotEmpty
        ? 'Hoi, $displayName!'
        : email.isNotEmpty
            ? 'Hoi, ${email.split('@').first}!'
            : 'Hoi!';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Roady'),
        backgroundColor: _bg,
        foregroundColor: _grey,
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/auth');
            },
            child: const Text('Uitloggen'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                welcome,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _grey,
                        ) ??
                    const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _grey,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kies wat je wilt doen',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: _grey),
              ),
              const SizedBox(height: 32),
              _DashboardCard(
                icon: Icons.menu_book,
                title: 'Lessen bekijken',
                subtitle: 'Bekijk lesmateriaal en maak oefenexamens',
                onTap: () => context.go('/app'),
              ),
              const SizedBox(height: 16),
              _DashboardCard(
                icon: Icons.payment,
                title: 'Abonnement kiezen',
                subtitle: 'Overgaan tot betaling voor Standaard of Met AI',
                onTap: () => context.go('/payment'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const _primary = Color(0xFFF97316);
  static const _grey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ) ??
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _grey,
                              ) ??
                          TextStyle(fontSize: 12, color: _grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
