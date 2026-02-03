import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/quiz_repository.dart';
import '../models/question.dart';
import 'result_screen.dart';

/// Quiz-scherm: één vraag per stap, meerkeuze, directe feedback en voortgang.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int? _chosenIndex;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await QuizRepository.loadQuestions();
      if (mounted) {
        setState(() {
          _questions = list..shuffle();
          _loading = false;
          _error = list.isEmpty ? 'Geen vragen geladen.' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Kon vragen niet laden: $e';
        });
      }
    }
  }

  void _onAnswerChosen(int index) {
    if (_chosenIndex != null) return;
    final q = _questions[_currentIndex];
    final correct = q.isCorrect(index);
    setState(() {
      _chosenIndex = index;
      if (correct) {
        _score += 10;
        _streak += 1;
      } else {
        _streak = 0;
      }
    });
  }

  void _goNext() {
    if (_currentIndex + 1 >= _questions.length) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ResultScreen(
            score: _score,
            total: _questions.length * 10,
            questionCount: _questions.length,
          ),
        ),
      );
      return;
    }
    setState(() {
      _currentIndex += 1;
      _chosenIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Vragen laden...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset(
            'images/logo-roady.svg',
            height: 28,
            fit: BoxFit.contain,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error ?? 'Geen vragen beschikbaar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Terug'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final hasChosen = _chosenIndex != null;

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'images/logo-roady.svg',
          height: 28,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Voortgang
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vraag ${_currentIndex + 1} / ${_questions.length}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      if (hasChosen && _streak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Reeks: $_streak',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E7D32),
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Score
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '$_score punten',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Vraag
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        q.text,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  height: 1.3,
                                ) ??
                            const TextStyle(
                              fontSize: 20,
                              height: 1.3,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(q.options.length, (i) {
                      final chosen = _chosenIndex == i;
                      final correct = q.correctIndex == i;
                      Color? bg;
                      Widget? trailing;
                      if (hasChosen) {
                        if (correct) {
                          bg = Colors.green.shade50;
                          trailing = Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 28,
                          );
                        } else if (chosen) {
                          bg = Colors.red.shade50;
                          trailing = Icon(
                            Icons.cancel,
                            color: Colors.red.shade700,
                            size: 28,
                          );
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: bg ?? Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          elevation: hasChosen ? 0 : 1,
                          shadowColor: Colors.black26,
                          child: InkWell(
                            onTap: hasChosen ? null : () => _onAnswerChosen(i),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasChosen && correct
                                      ? Colors.green.shade300
                                      : Colors.grey.shade200,
                                  width: hasChosen && correct ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      q.options[i],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: chosen || correct
                                                ? FontWeight.w600
                                                : null,
                                          ),
                                    ),
                                  ),
                                  if (trailing != null) ...[
                                    const SizedBox(width: 12),
                                    trailing,
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    if (hasChosen)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _goNext,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _currentIndex + 1 >= _questions.length
                                ? 'Bekijk resultaat'
                                : 'Volgende',
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
