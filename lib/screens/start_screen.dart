import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/user_language_repository.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  static const _heroBg = Color(0xFFe8f0e9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndNavigate());
  }

  Future<void> _checkAndNavigate() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    final language =
        await UserLanguageRepository.instance.getLanguage(user.uid);
    if (!mounted) return;
    if (language == null || language.isEmpty) {
      context.go('/language');
      return;
    }

    final licenseType =
        await UserLanguageRepository.instance.getLicenseType(user.uid);
    if (!mounted) return;
    if (licenseType == null || licenseType.isEmpty) {
      context.go('/license');
      return;
    }

    final examRegion =
        await UserLanguageRepository.instance.getExamRegion(user.uid);
    if (!mounted) return;
    if (examRegion == null || examRegion.isEmpty) {
      context.go('/region');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
