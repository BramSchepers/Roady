import 'dart:math' as math;

import '../models/energy_state.dart';
import '../models/theory_models.dart';
import '../widgets/energy_gauge.dart'; // Import the new widget
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background: white so overflow (large screens / scroll) shows white
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
                              if (context.mounted) {
                                context.go('/auth?mode=login');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Fuel Meter Section (Now RPM Gauge style)
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

/// Progress 0.0–1.0 afgeleid uit de lijst voltooide hoofdstukken (bron van waarheid).
double _progressFromCompletedLessons(List<String> completedIds) {
  int total = 0;
  for (var c in dummyChapters) {
    total += c.lessons.length;
  }
  if (total == 0) return 0.0;
  double p = 0.0;
  for (var id in completedIds) {
    for (var c in dummyChapters) {
      if (c.id == id) {
        p += c.lessons.length / total;
        break;
      }
    }
  }
  return p > 1.0 ? 1.0 : p;
}

String _getStatusText(double effective) {
  if (effective >= 1.0) return 'Klaar!';
  if (effective >= 0.90) return 'Laatste loodjes';
  if (effective >= 0.80) return 'Einde is inzicht';
  if (effective >= 0.70) return 'Bijna daar';
  if (effective >= 0.60) return 'Even doorzetten';
  if (effective >= 0.50) return 'Halverwege';
  if (effective >= 0.40) return 'Bijna';
  if (effective >= 0.30) return 'Goed bezig';
  if (effective >= 0.20) return 'Onderweg';
  if (effective >= 0.10) return 'Starter';
  return 'Net begonnen';
}

Color _getStatusColor(double effective) {
  if (effective >= 1.0) return Colors.green;
  if (effective >= 0.70) return Colors.green.shade300;
  if (effective >= 0.40) return Colors.blue;
  if (effective >= 0.10) return Colors.orange;
  return Colors.grey;
}

/// Curve: scale up (0→0.4) then plop back with bounce (0.4→1).
class _PlopCurve extends Curve {
  @override
  double transformInternal(double t) {
    if (t < 0.4) {
      return Curves.easeOut.transform(t / 0.4);
    }
    return 1.0 - Curves.elasticOut.transform((t - 0.4) / 0.6);
  }
}

/// Curve: damped left-right shake oscillation.
class _ShakeCurve extends Curve {
  @override
  double transformInternal(double t) {
    const cycles = 4.0;
    final decay = 1.0 - t;
    return math.sin(t * cycles * math.pi * 2) * decay;
  }
}

class _AnimatedStatusBadge extends StatefulWidget {
  const _AnimatedStatusBadge({
    required this.listenable,
    required this.state,
  });

  final Listenable listenable;
  final EnergyState state;

  @override
  State<_AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<_AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  String? _prevStatus;
  bool _initialized = false;

  static const double _shakeAmount = 6.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: _PlopCurve()),
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: _shakeAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: _ShakeCurve()));
    widget.listenable.addListener(_onUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onUpdate());
  }

  void _onUpdate() {
    final stored = widget.state.progress.value;
    final fromCompleted =
        _progressFromCompletedLessons(widget.state.completedLessons.value);
    final effective = fromCompleted > stored ? fromCompleted : stored;
    final status = _getStatusText(effective);

    if (_initialized && _prevStatus != null && _prevStatus != status) {
      _controller.forward(from: 0).then((_) => _controller.reset());
    }
    _prevStatus = status;
    _initialized = true;
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.listenable,
        _scaleAnimation,
        _shakeAnimation,
      ]),
      builder: (context, _) {
        final stored = widget.state.progress.value;
        final fromCompleted =
            _progressFromCompletedLessons(widget.state.completedLessons.value);
        final effective = fromCompleted > stored ? fromCompleted : stored;
        if (fromCompleted > stored) {
          widget.state.repairProgress(fromCompleted);
        }
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              _getStatusText(effective),
              style: TextStyle(
                color: _getStatusColor(effective),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}

class FuelMeterCard extends StatelessWidget {
  const FuelMeterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EnergyState();
    final listenable =
        Listenable.merge([state.progress, state.completedLessons]);

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
                child: _AnimatedStatusBadge(
                  listenable: listenable,
                  state: state,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // RPM / Energy Gauge (zelfde effective progress)
          AnimatedBuilder(
            animation: listenable,
            builder: (context, _) {
              final stored = state.progress.value;
              final fromCompleted =
                  _progressFromCompletedLessons(state.completedLessons.value);
              final effective = fromCompleted > stored ? fromCompleted : stored;
              if (fromCompleted > stored) {
                state.repairProgress(fromCompleted);
              }
              return EnergyGauge(
                percentage: effective,
                size: 220,
              );
            },
          ),

          const SizedBox(height: 28),
          Text(
            'Voltooi meer cursussen om je tank te vullen!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Voortgang resetten?'),
                  content: const Text(
                    'Alle voltooide lessen en je tank worden geleegd. Je kunt daarna alles opnieuw doornemen.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Annuleren'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await EnergyState().resetProgress();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Voortgang gereset. Je kunt opnieuw beginnen.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
            label: const Text(
              'Reset voortgang',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
