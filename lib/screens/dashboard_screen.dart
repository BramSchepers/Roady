import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _heroBg = Color(0xFFe8f0e9);
  static const _accentBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _heroBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SvgPicture.asset(
          'assets/images/logo-roady.svg',
          height: 32,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(_accentBlue, BlendMode.srcIn),
          errorBuilder: (_, __, ___) => const Text('Roady',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _accentBlue)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/auth');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
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
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Hier komt het dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
