import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown on web when mobile/tablet browser detected.
/// Prompts user to download the app, with escape to use web anyway.
class DownloadAppScreen extends StatelessWidget {
  const DownloadAppScreen({super.key});

  static const _accentBlue = Color(0xFF2563EB);

  /// Play Store URL - update id if your package differs.
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.roady';

  /// App Store URL - replace XXXXX with your app's Apple ID.
  static const _appStoreUrl = 'https://apps.apple.com/app/roady/idXXXXX';

  static const _prefKeyWebOptedIn = 'roady_web_opted_in';

  static Future<void> setWebOptedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyWebOptedIn, value);
  }

  static Future<bool> getWebOptedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyWebOptedIn) ?? false;
  }

  Future<void> _openPlayStore(BuildContext context) async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openAppStore(BuildContext context) async {
    final uri = Uri.parse(_appStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _useWebAnyway(BuildContext context) async {
    await setWebOptedIn(true);
    if (context.mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Image.asset(
                      'assets/images/logo-roady.png',
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_car,
                        size: 64,
                        color: _accentBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Download de Roady app',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Voor de beste ervaring op mobiel raden we je aan de app te downloaden.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[900],
                        ),
                  ),
                  const SizedBox(height: 40),
                  // Play Store
                  _StoreButton(
                    icon: Icons.android,
                    label: 'Download voor Android',
                    subtitle: 'Google Play Store',
                    onTap: () => _openPlayStore(context),
                  ),
                  const SizedBox(height: 16),
                  // App Store
                  _StoreButton(
                    icon: Icons.apple,
                    label: 'Download voor iOS',
                    subtitle: 'App Store',
                    onTap: () => _openAppStore(context),
                  ),
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => _useWebAnyway(context),
                    child: const Text('Toch webversie gebruiken'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _StoreButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DownloadAppScreen._accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: DownloadAppScreen._accentBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: DownloadAppScreen._accentBlue,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
