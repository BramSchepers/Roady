import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../debug_log.dart';
import 'quiz_screen.dart';
import 'study_material_placeholder_screen.dart';

/// Home volgens Figma: titel, mascot, welkomst, progress-kaart, Study Material + Practice Exam.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _bg = Color(0xFFF5F7FA);
  static const _primaryBlue = Color(0xFF1A56DB);
  static const _yellow = Color(0xFFFFD700);
  static const _grey = Color(0xFF6B7280);
  static const _lightGrey = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    // #region agent log
    debugLogFire('home_screen.dart:HomeScreen.build', 'HomeScreen.build() entry', 'H3');
    // #endregion
    final widget = Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              SvgPicture.asset(
                'images/logo-roady.svg',
                width: 260,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Image.asset(
                'images/Roady_mascot_nobackground.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _grey,
                      ) ??
                      const TextStyle(fontSize: 16, color: _grey),
                  children: [
                    const TextSpan(text: "Hoi! Ik ben "),
                    const TextSpan(
                      text: 'GetRoady',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ", je studiebuddy! "),
                    const TextSpan(text: '🚗'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _ProgressCard(primaryBlue: _primaryBlue, grey: _grey, lightGrey: _lightGrey),
              const SizedBox(height: 28),
              _ActionButton(
                label: 'Lesmateriaal',
                icon: Icons.menu_book,
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const StudyMaterialPlaceholderScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _ActionButton(
                label: 'Oefenexamen',
                icon: Icons.assignment_turned_in,
                backgroundColor: _yellow,
                foregroundColor: _primaryBlue,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const QuizScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
    // #region agent log
    debugLogFire('home_screen.dart:HomeScreen.build', 'HomeScreen.build() returning widget', 'H4');
    // #endregion
    return widget;
  }
}

class _ProgressCard extends StatelessWidget {
  final Color primaryBlue;
  final Color grey;
  final Color lightGrey;

  const _ProgressCard({
    required this.primaryBlue,
    required this.grey,
    required this.lightGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: 0.67,
                    strokeWidth: 12,
                    backgroundColor: lightGrey.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                  ),
                ),
                Text(
                  '67%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ) ??
                      TextStyle(
                        fontSize: 22,
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Examenbereidheid',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: grey,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Blijf oefenen!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: lightGrey,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: foregroundColor, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: foregroundColor, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
