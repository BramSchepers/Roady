import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language option for UI (language selection screen + profile dropdown).
class LanguageOption {
  const LanguageOption({
    required this.id,
    required this.label,
    required this.active,
  });
  final String id;
  final String label;
  final bool active;
}

const List<LanguageOption> kLanguageOptions = [
  LanguageOption(id: 'nl', label: 'Nederlands', active: true),
  LanguageOption(id: 'fr', label: 'Français', active: false),
  LanguageOption(id: 'en', label: 'English', active: false),
];

const String _languagePrefKeyPrefix = 'user_language_';
const String _licenseTypePrefKeyPrefix = 'license_type_';
const String _examRegionPrefKeyPrefix = 'exam_region_';
const String _usersCollection = 'users';
const String _languageField = 'language';
const String _licenseTypeField = 'licenseType';
const String _examRegionField = 'examRegion';

/// Offline-first: local (SharedPreferences) voor snelle reads/writes,
/// Firestore sync in de achtergrond wanneer er internet is.
class UserLanguageRepository {
  UserLanguageRepository._();
  static final UserLanguageRepository instance = UserLanguageRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Leest eerst lokaal (snel, offline). Als online: sync van Firestore in achtergrond.
  Future<String?> getLanguage(String uid) async {
    final cached = await _getCachedLanguage(uid);
    _syncFromFirestoreInBackground(uid);
    return cached;
  }

  /// Voor flow waar we wachten op Firestore als er nog geen lokale waarde is (bv. eerste keer).
  Future<String?> getLanguageOrFetch(String uid) async {
    final cached = await _getCachedLanguage(uid);
    if (cached != null && cached.isNotEmpty) return cached;
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      final language = doc.data()?[_languageField] as String?;
      if (language != null && language.isNotEmpty) {
        await _cacheLanguage(uid, language);
        return language;
      }
    } catch (_) {}
    return null;
  }

  void _syncFromFirestoreInBackground(String uid) {
    _firestore.collection(_usersCollection).doc(uid).get().then((doc) {
      final data = doc.data();
      if (data == null) return;
      final language = data[_languageField] as String?;
      if (language != null && language.isNotEmpty) {
        _cacheLanguage(uid, language);
      }
      final licenseType = data[_licenseTypeField] as String?;
      if (licenseType != null && licenseType.isNotEmpty) {
        _cacheLicenseType(uid, licenseType);
      }
      final examRegion = data[_examRegionField] as String?;
      if (examRegion != null && examRegion.isNotEmpty) {
        _cacheExamRegion(uid, examRegion);
      }
    }).catchError((_) {});
  }

  /// Slaat direct lokaal op (snel), sync naar Firestore in achtergrond.
  Future<void> setLanguage(String uid, String languageCode) async {
    await _cacheLanguage(uid, languageCode);
    _syncToFirestoreInBackground(uid, languageCode);
  }

  void _syncToFirestoreInBackground(String uid, String languageCode) {
    _firestore.collection(_usersCollection).doc(uid).set(
      {_languageField: languageCode},
      SetOptions(merge: true),
    ).catchError((_) {});
  }

  /// Rijbewijstype: eerst cache, anders Firestore ophalen; daarna sync in achtergrond.
  Future<String?> getLicenseType(String uid) async {
    final cached = await _getCachedLicenseType(uid);
    if (cached != null && cached.isNotEmpty) {
      _syncFromFirestoreInBackground(uid);
      return cached;
    }
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      final licenseType = doc.data()?[_licenseTypeField] as String?;
      if (licenseType != null && licenseType.isNotEmpty) {
        await _cacheLicenseType(uid, licenseType);
        return licenseType;
      }
    } catch (_) {}
    return null;
  }

  /// Slaat rijbewijstype lokaal op en sync naar Firestore (merge met bestaand document).
  Future<void> setLicenseType(String uid, String value) async {
    await _cacheLicenseType(uid, value);
    _firestore.collection(_usersCollection).doc(uid).set(
      {_licenseTypeField: value},
      SetOptions(merge: true),
    ).catchError((_) {});
  }

  /// Examregio: eerst cache, anders Firestore ophalen; daarna sync in achtergrond.
  Future<String?> getExamRegion(String uid) async {
    final cached = await _getCachedExamRegion(uid);
    if (cached != null && cached.isNotEmpty) {
      _syncFromFirestoreInBackground(uid);
      return cached;
    }
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      final examRegion = doc.data()?[_examRegionField] as String?;
      if (examRegion != null && examRegion.isNotEmpty) {
        await _cacheExamRegion(uid, examRegion);
        return examRegion;
      }
    } catch (_) {}
    return null;
  }

  /// Slaat examregio lokaal op en sync naar Firestore (merge met bestaand document).
  Future<void> setExamRegion(String uid, String value) async {
    await _cacheExamRegion(uid, value);
    _firestore.collection(_usersCollection).doc(uid).set(
      {_examRegionField: value},
      SetOptions(merge: true),
    ).catchError((_) {});
  }

  Future<String?> _getCachedLicenseType(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_licenseTypePrefKeyPrefix$uid');
  }

  Future<void> _cacheLicenseType(String uid, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_licenseTypePrefKeyPrefix$uid', value);
  }

  Future<String?> _getCachedExamRegion(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_examRegionPrefKeyPrefix$uid');
  }

  Future<void> _cacheExamRegion(String uid, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_examRegionPrefKeyPrefix$uid', value);
  }

  Future<String?> _getCachedLanguage(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_languagePrefKeyPrefix$uid');
  }

  Future<void> _cacheLanguage(String uid, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_languagePrefKeyPrefix$uid', languageCode);
  }
}
