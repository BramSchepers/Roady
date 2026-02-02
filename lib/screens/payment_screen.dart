import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Placeholder voor betaling: toont gekozen plan, prijs, knop "Doorgaan naar betaling".
/// Plan komt van query param (?plan=free|standard|ai) of wordt gekozen op dit scherm.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _keyPlan = 'roady_selected_plan';

  String? _plan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final plan = GoRouterState.of(context).uri.queryParameters['plan'];
    if (plan != null && _plan != plan) {
      setState(() => _plan = plan);
      _persistPlan(plan);
    }
  }

  Future<void> _persistPlan(String plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlan, plan);
  }

  static const _plans = {
    'free': ('Gratis', '€0', 'Basis oefenen'),
    'standard': ('Standaard', '4,99 € / 2 maanden', 'Meer mogelijkheden'),
    'ai': ('Met AI', '9,99 € / 2 maanden', 'Aanbevolen'),
  };

  static const _primary = Color(0xFFF97316);
  static const _bg = Color(0xFFF5F7FA);
  static const _grey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final planFromRoute = GoRouterState.of(context).uri.queryParameters['plan'];
    final current = _plan ?? planFromRoute;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Abonnement'),
        backgroundColor: _bg,
        foregroundColor: _grey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              if (current == null) ...[
                Text(
                  'Kies een abonnement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                ..._plans.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        planKey: e.key,
                        title: e.value.$1,
                        price: e.value.$2,
                        subtitle: e.value.$3,
                        onTap: () {
                          setState(() => _plan = e.key);
                          _persistPlan(e.key);
                        },
                      ),
                    )),
              ] else ...[
                Text(
                  'Je gekozen plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _PlanSummaryCard(
                  title: _plans[current]!.$1,
                  price: _plans[current]!.$2,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Betaling wordt later geïntegreerd (bijv. Stripe).',
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Doorgaan naar betaling'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _plan = null),
                  child: const Text('Ander plan kiezen'),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.planKey,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.onTap,
  });

  final String planKey;
  final String title;
  final String price;
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _grey,
                          ),
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

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.title, required this.price});

  final String title;
  final String price;

  static const _primary = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
