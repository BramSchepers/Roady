import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Opgeslagen oefenvraag-ids per gebruiker in Firestore (users/{uid}).
/// Alleen voor ingelogde gebruikers; cross-platform sync.
class SavedQuestionsRepository {
  SavedQuestionsRepository._();
  static final SavedQuestionsRepository instance = SavedQuestionsRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  static const String _savedIdsField = 'savedQuizQuestionIds';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Leest opgeslagen vraag-ids; lege lijst als niet ingelogd.
  Future<List<String>> getSavedQuestionIds() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      final data = doc.data();
      if (data == null) return [];
      final raw = data[_savedIdsField];
      if (raw is! List) return [];
      return raw
          .map((e) => e?.toString())
          .where((s) => s != null && s.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Voegt een vraag-id toe (geen duplicaten); no-op als niet ingelogd.
  Future<void> addSavedQuestionId(String questionId) async {
    final uid = _uid;
    if (uid == null || questionId.isEmpty) return;
    try {
      final ref = _firestore.collection(_usersCollection).doc(uid);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = _parseList(snap.data());
        if (current.contains(questionId)) return;
        tx.set(ref, {_savedIdsField: [...current, questionId]}, SetOptions(merge: true));
      });
    } catch (_) {}
  }

  /// Verwijdert een vraag-id; no-op als niet ingelogd.
  Future<void> removeSavedQuestionId(String questionId) async {
    final uid = _uid;
    if (uid == null || questionId.isEmpty) return;
    try {
      final ref = _firestore.collection(_usersCollection).doc(uid);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = _parseList(snap.data());
        final next = current.where((id) => id != questionId).toList();
        tx.set(ref, {_savedIdsField: next}, SetOptions(merge: true));
      });
    } catch (_) {}
  }

  /// Toggle: als opgeslagen dan verwijderen, anders toevoegen.
  Future<void> toggleSavedQuestionId(String questionId) async {
    final saved = await isSaved(questionId);
    if (saved) {
      await removeSavedQuestionId(questionId);
    } else {
      await addSavedQuestionId(questionId);
    }
  }

  /// Of deze vraag opgeslagen is; false als niet ingelogd.
  Future<bool> isSaved(String questionId) async {
    final ids = await getSavedQuestionIds();
    return ids.contains(questionId);
  }

  static List<String> _parseList(Map<String, dynamic>? data) {
    if (data == null) return [];
    final raw = data[_savedIdsField];
    if (raw is! List) return [];
    return raw
        .map((e) => e?.toString())
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
  }
}
