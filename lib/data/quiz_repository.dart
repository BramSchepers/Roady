import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';

/// Laadt vragen uit assets/questions.json.
class QuizRepository {
  static Future<List<Question>> loadQuestions() async {
    final String raw =
        await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> list = data['questions'] as List<dynamic>? ?? [];
    return list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
