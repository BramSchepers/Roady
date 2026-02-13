import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/exam_attempt.dart';

class ExamHistoryRepository {
  static final ExamHistoryRepository _instance =
      ExamHistoryRepository._internal();
  static ExamHistoryRepository get instance => _instance;
  ExamHistoryRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionId = 'examAttempts';

  /// Saves an exam attempt. Requires attempt.userId == currentUser.uid.
  /// Returns the Firestore document id, or null if not saved.
  Future<String?> saveAttempt(ExamAttempt attempt) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || attempt.userId != uid) return null;
    final ref = await _firestore.collection(_collectionId).add(attempt.toMap());
    return ref.id;
  }

  /// Stream of attempts for the current user, newest first.
  /// Tied to auth: when user logs out, the Firestore listen is cancelled to avoid PERMISSION_DENIED.
  Stream<List<ExamAttempt>> streamAttempts() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(<ExamAttempt>[]);
      return _firestore
          .collection(_collectionId)
          .where('userId', isEqualTo: user.uid)
          .orderBy('completedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ExamAttempt.fromMap(doc.id, doc.data()))
              .toList());
    });
  }

  /// Fetches a single attempt by id (from cache when offline).
  Future<ExamAttempt?> getAttempt(String attemptId) async {
    final doc = await _firestore.collection(_collectionId).doc(attemptId).get();
    if (doc.data() == null) return null;
    return ExamAttempt.fromMap(doc.id, doc.data()!);
  }
}
