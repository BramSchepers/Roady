enum QuestionType {
  multipleChoice,
  yesNo,
  hazardPerception, // Gevaarherkenning
}

enum QuizMode {
  trafficSigns, // Verkeersborden
  chapter, // Per hoofdstuk
  random, // Willekeurig
  exam, // Examen simulatie
}

class QuizQuestion {
  final String id;
  final String text;
  final String? imageUrl;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final QuestionType type;
  final String category; // 'traffic_signs', 'general', 'hazard', etc.
  /// Aftrek bij fout: 1 (kleine fout) of 5 (zware fout).
  final int pointsDeductionIfWrong;

  /// 0 = niet in examen, 1 = wel in examen.
  final int useInExam;

  const QuizQuestion({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.type,
    required this.category,
    this.pointsDeductionIfWrong = 1,
    this.useInExam = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'type': type.name,
      'category': category,
      'pointsDeductionIfWrong': pointsDeductionIfWrong,
      'useInExam': useInExam,
    };
  }

  /// Parses an int from Firestore (can be int, double, or String).
  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely parse options (Firestore can return List<dynamic> or mixed types).
  static List<String> _parseOptions(dynamic value) {
    if (value == null || value is! List) return [];
    final list = <String>[];
    for (final e in value) {
      if (e == null) continue;
      list.add(e is String ? e : e.toString());
    }
    return list;
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    final options = _parseOptions(map['options']);
    final rawCorrect = _parseInt(map['correctOptionIndex'], 0);
    final correctOptionIndex = options.isEmpty
        ? 0
        : rawCorrect.clamp(0, options.length - 1);
    QuestionType type = QuestionType.multipleChoice;
    try {
      final typeStr = map['type']?.toString();
      if (typeStr != null) {
        type = QuestionType.values.firstWhere(
          (e) => e.name == typeStr,
          orElse: () => QuestionType.multipleChoice,
        );
      }
    } catch (_) {}
    return QuizQuestion(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      options: options,
      correctOptionIndex: correctOptionIndex,
      explanation: map['explanation']?.toString() ?? '',
      type: type,
      category: map['category']?.toString() ?? 'general',
      pointsDeductionIfWrong: _parseInt(map['pointsDeductionIfWrong'], 1),
      useInExam: _parseInt(map['useInExam'], 0),
    );
  }
}

class QuizSession {
  final String id;
  final QuizMode mode;
  final List<QuizQuestion> questions;
  final int startTime; // Timestamp

  const QuizSession({
    required this.id,
    required this.mode,
    required this.questions,
    required this.startTime,
  });
}
