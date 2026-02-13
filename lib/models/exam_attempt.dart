import 'package:cloud_firestore/cloud_firestore.dart';

import 'quiz_models.dart';

/// Result of a single question in an exam attempt (snapshot for offline/review).
class QuestionResult {
  /// Frozen question data (from QuizQuestion.toMap(), includes category).
  final Map<String, dynamic> questionSnapshot;
  /// Index of the option the user selected, or null if timed out.
  final int? selectedOptionIndex;
  final bool correct;
  final bool timedOut;

  const QuestionResult({
    required this.questionSnapshot,
    required this.selectedOptionIndex,
    required this.correct,
    required this.timedOut,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionSnapshot': questionSnapshot,
      'selectedOptionIndex': selectedOptionIndex,
      'correct': correct,
      'timedOut': timedOut,
    };
  }

  factory QuestionResult.fromMap(Map<String, dynamic> map) {
    final snapshot = map['questionSnapshot'];
    return QuestionResult(
      questionSnapshot: snapshot is Map<String, dynamic>
          ? Map<String, dynamic>.from(snapshot)
          : {},
      selectedOptionIndex: map['selectedOptionIndex'] as int?,
      correct: map['correct'] as bool? ?? false,
      timedOut: map['timedOut'] as bool? ?? false,
    );
  }

  /// Convenience: get QuizQuestion from snapshot for display.
  QuizQuestion get question => QuizQuestion.fromMap(questionSnapshot);
}


/// One exam attempt (50 questions), stored in Firestore for history and review.
class ExamAttempt {
  final String? id;
  final String userId;
  final DateTime completedAt;
  final int score;
  final bool passed;
  final List<QuestionResult> questionResults;

  const ExamAttempt({
    this.id,
    required this.userId,
    required this.completedAt,
    required this.score,
    required this.passed,
    required this.questionResults,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completedAt': Timestamp.fromDate(completedAt),
      'score': score,
      'passed': passed,
      'questionResults': questionResults.map((q) => q.toMap()).toList(),
    };
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory ExamAttempt.fromMap(String id, Map<String, dynamic> map) {
    final completedAt = map['completedAt'];
    DateTime date = DateTime.now();
    if (completedAt is Timestamp) {
      date = completedAt.toDate();
    } else if (completedAt is DateTime) {
      date = completedAt;
    }
    final resultsRaw = map['questionResults'];
    final List<QuestionResult> results = [];
    if (resultsRaw is List) {
      for (final item in resultsRaw) {
        if (item is Map<String, dynamic>) {
          results.add(QuestionResult.fromMap(item));
        }
      }
    }
    return ExamAttempt(
      id: id,
      userId: map['userId'] as String? ?? '',
      completedAt: date,
      score: _parseInt(map['score'], 0),
      passed: map['passed'] as bool? ?? false,
      questionResults: results,
    );
  }
}
