import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Key used for both web (localStorage) and app (SharedPreferences) so consent
/// is consistent if the user visits both.
const String kAnalyticsConsentKey = 'roady_cookie_consent';

const String _consentAccepted = 'accepted';
const String _consentRejected = 'rejected';

/// Manages analytics consent (GDPR): persist choice and enable/disable Firebase Analytics.
/// On web we do not show this UI (cookie banner on static site); only iOS/Android use this.
class AnalyticsConsentService {
  AnalyticsConsentService._();

  static final AnalyticsConsentService instance = AnalyticsConsentService._();

  /// Returns null if not yet chosen, 'accepted' or 'rejected' otherwise.
  Future<String?> getConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(kAnalyticsConsentKey);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if user has already made a choice (accept or reject).
  Future<bool> hasConsentChoice() async {
    final value = await getConsent();
    return value == _consentAccepted || value == _consentRejected;
  }

  /// Save consent and apply to Firebase Analytics (app only).
  Future<void> setConsent(bool accepted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kAnalyticsConsentKey,
        accepted ? _consentAccepted : _consentRejected,
      );
    } catch (_) {}
    await _applyToFirebase(accepted);
  }

  /// Apply stored consent to Firebase Analytics. Call at startup (app only).
  Future<void> applyStoredConsent() async {
    if (kIsWeb) return;
    final consent = await getConsent();
    await _applyToFirebase(consent == _consentAccepted);
  }

  Future<void> _applyToFirebase(bool enable) async {
    if (kIsWeb) return;
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enable);
    } catch (_) {}
  }
}
