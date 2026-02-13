import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/exam_attempt.dart';
import '../repositories/exam_history_repository.dart';

class ExamReviewScreen extends StatefulWidget {
  final String attemptId;

  const ExamReviewScreen({super.key, required this.attemptId});

  @override
  State<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends State<ExamReviewScreen> {
  ExamAttempt? _attempt;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final attempt =
        await ExamHistoryRepository.instance.getAttempt(widget.attemptId);
    if (mounted) {
      setState(() {
        _attempt = attempt;
        _loading = false;
        _error = attempt == null ? 'Poging niet gevonden' : null;
      });
    }
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Examen terugblik')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_attempt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Examen terugblik')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? 'Poging niet gevonden',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ),
      );
    }
    final attempt = _attempt!;
    const accentBlue = Color(0xFF2563EB);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Examen terugblik'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(attempt.completedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${attempt.score}/50',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      attempt.passed ? Icons.check_circle : Icons.cancel,
                      size: 22,
                      color: attempt.passed ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attempt.passed ? 'Geslaagd' : 'Niet geslaagd',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attempt.questionResults.length,
              itemBuilder: (context, index) {
                final result = attempt.questionResults[index];
                Color iconColor;
                IconData iconData;
                String label;
                if (result.timedOut) {
                  iconColor = Colors.orange;
                  iconData = Icons.schedule;
                  label = 'Tijd verstreken';
                } else if (result.correct) {
                  iconColor = Colors.green;
                  iconData = Icons.check_circle;
                  label = 'Juist';
                } else {
                  iconColor = Colors.red;
                  iconData = Icons.cancel;
                  label = 'Fout';
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _openQuestionDetail(attempt, index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(iconData, size: 24, color: iconColor),
                            const SizedBox(width: 12),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                color: iconColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: accentBlue),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openQuestionDetail(ExamAttempt attempt, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ExamReviewQuestionPage(
          attempt: attempt,
          questionIndex: index,
        ),
      ),
    );
  }
}

/// Full-screen page showing one question with explanation (read-only).
class _ExamReviewQuestionPage extends StatelessWidget {
  final ExamAttempt attempt;
  final int questionIndex;

  const _ExamReviewQuestionPage({
    required this.attempt,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final result = attempt.questionResults[questionIndex];
    final question = result.question;
    final selectedIndex = result.selectedOptionIndex;
    final correctIndex = question.correctOptionIndex;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Vraag ${questionIndex + 1} / ${attempt.questionResults.length}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (question.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: CachedNetworkImage(
                    imageUrl: question.imageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (result.timedOut)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule,
                        color: Colors.orange.shade700, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Tijd verstreken – vraag als fout gerekend.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.orange.shade900),
                    ),
                  ],
                ),
              ),
            if (result.timedOut) const SizedBox(height: 16),
            ...List.generate(question.options.length, (index) {
              final isSelected = selectedIndex == index;
              final isCorrect = index == correctIndex;
              Color? backgroundColor;
              Color borderColor = Colors.grey.shade300;
              Color textColor = Colors.black87;
              String? suffix;
              if (isCorrect) {
                backgroundColor = Colors.green.shade50;
                borderColor = Colors.green;
                textColor = Colors.green.shade900;
                suffix = 'Juiste antwoord';
              }
              if (isSelected && !isCorrect) {
                backgroundColor = Colors.red.shade50;
                borderColor = Colors.red;
                textColor = Colors.red.shade900;
                suffix = 'Jouw antwoord';
              }
              if (isSelected && isCorrect) {
                suffix = 'Jouw antwoord · Juiste antwoord';
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.white,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.options[index],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (suffix != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                suffix,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: borderColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green),
                      if (isSelected && !isCorrect)
                        const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Uitleg',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
