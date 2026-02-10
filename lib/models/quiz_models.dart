enum QuestionType {
  multipleChoice,
  yesNo,
  hazardPerception, // Gevaarherkenning
}

enum QuizMode {
  trafficSigns, // Verkeersborden
  chapter,      // Per hoofdstuk
  random,       // Willekeurig
  exam,         // Examen simulatie
}

class QuizQuestion {
  final String id;
  final String text;
  final String? imageUrl;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final QuestionType type;

  const QuizQuestion({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.type,
  });
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
