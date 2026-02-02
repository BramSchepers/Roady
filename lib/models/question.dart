/// Model voor één quizvraag.
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
    );
  }

  bool isCorrect(int chosenIndex) => chosenIndex == correctIndex;
}
