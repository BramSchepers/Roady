import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/user_language_repository.dart';
import '../auth/user_profile_prefs.dart';
import '../widgets/subscription_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _licenseType;
  bool _licenseLoaded = false;
  String? _language;
  bool _languageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLicenseType();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _languageLoaded = true);
      return;
    }
    final value = await UserLanguageRepository.instance.getLanguage(uid);
    if (mounted) setState(() {
      _language = value;
      _languageLoaded = true;
    });
  }

  Future<void> _onLanguageChanged(String? newValue) async {
    if (newValue == null) return;
    LanguageOption? option;
    for (final o in kLanguageOptions) {
      if (o.id == newValue) {
        option = o;
        break;
      }
    }
    if (option == null || !option.active) {
      if (mounted) setState(() {});
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await UserLanguageRepository.instance.setLanguage(uid, newValue);
    if (mounted) setState(() => _language = newValue);
  }

  Future<void> _loadLicenseType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _licenseLoaded = true);
      return;
    }
    final value = await UserLanguageRepository.instance.getLicenseType(uid);
    if (mounted) setState(() {
      _licenseType = value;
      _licenseLoaded = true;
    });
  }

  Future<void> _onLicenseTypeChanged(String? newValue) async {
    if (newValue == null) return;
    LicenseTypeOption? option;
    for (final o in kLicenseTypeOptions) {
      if (o.id == newValue) {
        option = o;
        break;
      }
    }
    if (option == null || !option.active) {
      if (mounted) setState(() {});
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await UserLanguageRepository.instance.setLicenseType(uid, newValue);
    if (mounted) setState(() => _licenseType = newValue);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Geen email gevonden';
    final name = user?.displayName ?? 'Gebruiker';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profiel'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture Placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF2563EB), // Accent blue
              ),
            ),
            const SizedBox(height: 16),
            // User Info
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Instellingen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_languageLoaded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _language != null &&
                          kLanguageOptions.any((o) => o.id == _language)
                      ? _language
                      : null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Taal',
                    alignLabelWithHint: true,
                  ),
                  items: kLanguageOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.id,
                      child: Row(
                        children: [
                          Text(
                            option.label,
                            style: option.active
                                ? null
                                : TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                          ),
                          if (!option.active) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Coming soon',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onLanguageChanged,
                ),
              ),
            if (_languageLoaded) const SizedBox(height: 16),
            if (_licenseLoaded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _licenseType != null &&
                          kLicenseTypeOptions.any((o) => o.id == _licenseType)
                      ? _licenseType
                      : null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Rijbewijstype',
                    alignLabelWithHint: true,
                  ),
                  items: kLicenseTypeOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.id,
                      child: Row(
                        children: [
                          Text(
                            option.label,
                            style: option.active
                                ? null
                                : TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                          ),
                          if (!option.active) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(Binnenkort)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _onLicenseTypeChanged,
                ),
              ),
            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mijn Abonnement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Show only the current subscription (assuming Free for now)
            SubscriptionCard(
              title: 'Gratis',
              price: '€0 / maand',
              features: const ['Basis theorie', 'Beperkte examens'],
              color: Colors.blue.shade50,
              textColor: Colors.blue.shade900,
              isCurrent: true,
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/dashboard?tab=3'), // Go to Shop
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upgrade Abonnement',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
