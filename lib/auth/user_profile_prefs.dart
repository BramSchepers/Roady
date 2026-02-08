import 'package:shared_preferences/shared_preferences.dart';

/// Central definition of a license type for UI (onboarding + profile dropdown).
class LicenseTypeOption {
  const LicenseTypeOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.active,
  });

  final String id;
  final String label;
  final String subtitle;
  final bool active;
}

/// All possible license types. B is active; A is visible but not yet active.
const List<LicenseTypeOption> kLicenseTypeOptions = [
  LicenseTypeOption(
    id: 'B',
    label: 'Rijbewijs B',
    subtitle: 'Auto',
    active: true,
  ),
  LicenseTypeOption(
    id: 'A',
    label: 'Rijbewijs A',
    subtitle: 'Motor',
    active: false,
  ),
];

const String _keyPrefix = 'license_type_';

/// User-scoped license type (and optional profile) persistence via SharedPreferences.
class UserProfilePrefs {
  UserProfilePrefs._();
  static final UserProfilePrefs instance = UserProfilePrefs._();

  Future<String?> getLicenseType(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefix$uid');
  }

  Future<void> setLicenseType(String uid, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$uid', value);
  }
}
