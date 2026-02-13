import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/energy_state.dart';
import '../models/exam_attempt.dart';
import '../models/quiz_models.dart';
import '../repositories/exam_history_repository.dart';
import '../repositories/quiz_repository.dart';

class QuizScreen extends StatefulWidget {
  final QuizMode mode;
  final String? categoryId;
  final bool ttsEnabled;

  const QuizScreen({
    super.key,
    required this.mode,
    this.categoryId,
    this.ttsEnabled = true,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  // State for current question
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  /// Shuffled options for current question (so users can't memorize positions).
  List<String> _shuffledOptions = [];
  /// Index in _shuffledOptions of the correct answer.
  int _correctShuffledIndex = 0;
  /// Maps shuffled position -> original index (for QuestionResult).
  List<int> _shuffledIndices = [];

  /// True when question was ended by timeout (do not show correct answer).
  bool _timedOutWithoutAnswer = false;

  // Score: for non-exam, count correct; for exam, start at 50 and subtract
  int _score = 0;
  int _examScore = 50;

  /// Collected per-question results for exam mode (for history).
  final List<QuestionResult> _questionResults = [];

  // Exam mode: TTS and timer
  FlutterTts? _flutterTts;
  bool _ttsReady = false;
  int? _examTimerRemaining;
  Timer? _examTimer;

  /// Smooth animation for timer bar (0 → 1 over 15s); bar value = 1 - this.
  late AnimationController _timerBarController;

  /// TTS on/off in exam (can be toggled from app bar).
  bool _ttsEnabled = true;

  /// 15 seconds per question (Vlaanderen exam rule).
  static const int _examTimerSeconds = 15;
  static const int _passingScore = 41;

  bool get _isExamMode => widget.mode == QuizMode.exam;

  bool get _effectiveTtsEnabled => _isExamMode ? _ttsEnabled : true;

  @override
  void initState() {
    super.initState();
    _ttsEnabled = widget.ttsEnabled;
    _timerBarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _examTimerSeconds),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _timerBarController.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await QuizRepository.instance.getQuestionsByMode(
      widget.mode,
      chapterId: widget.categoryId,
    );
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      _prepareQuestionOptions();
      if (_isExamMode && _questions.isNotEmpty) {
        _startTtsForCurrentQuestion();
      }
    }
  }

  /// Shuffles answer options for the current question so users can't memorize positions.
  void _prepareQuestionOptions() {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;
    final q = _questions[_currentIndex];
    if (q.options.isEmpty) return;
    final indices = List.generate(q.options.length, (i) => i)..shuffle();
    final correctPos = indices.indexOf(q.correctOptionIndex.clamp(0, q.options.length - 1));
    setState(() {
      _shuffledOptions = indices.map((i) => q.options[i]).toList();
      _shuffledIndices = indices;
      _correctShuffledIndex = correctPos >= 0 ? correctPos : 0;
    });
  }

  Future<void> _startTtsForCurrentQuestion() async {
    if (!mounted || _questions.isEmpty) return;
    final question = _questions[_currentIndex];
    setState(() {
      _ttsReady = false;
      _examTimerRemaining = null;
    });

    Future<void> startTimer() async {
      if (!mounted) return;
      if (_examTimerRemaining != null) return;
      setState(() {
        _ttsReady = true;
        _examTimerRemaining = _examTimerSeconds;
      });
      _timerBarController.reset();
      _timerBarController.forward();
      _examTimer?.cancel();
      _examTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_examTimerRemaining == null || _examTimerRemaining! <= 1) {
            _examTimerRemaining = null;
            _examTimer?.cancel();
            _timerBarController.stop();
            _onExamTimeUp();
          } else {
            _examTimerRemaining = _examTimerRemaining! - 1;
          }
        });
      });
    }

    if (!_effectiveTtsEnabled) {
      await startTimer();
      return;
    }

    try {
      _flutterTts ??= FlutterTts();
      // Use 'nl' on web for better browser support; 'nl-BE' on mobile
      await _flutterTts!.setLanguage(kIsWeb ? 'nl' : 'nl-BE');
      await _flutterTts!.setSpeechRate(0.45);

      _flutterTts!.setCompletionHandler(() {
        if (mounted && !_ttsReady) startTimer();
      });

      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted && !_ttsReady) await startTimer();
      });

      await _flutterTts!.speak(question.text);
    } catch (_) {
      // TTS failed (e.g. web Speech API unavailable) → start timer immediately
      if (mounted && !_ttsReady) await startTimer();
    }
  }

  void _onExamTimeUp() {
    if (_isAnswered) return;
    final q = _questions[_currentIndex];

    setState(() {
      _isAnswered = true;
      _timedOutWithoutAnswer =
          true; // do not show correct answer to avoid confusion
      _examScore = (_examScore - q.pointsDeductionIfWrong).clamp(0, 50);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _nextQuestion();
    });
  }

  void _handleAnswer(int index) {
    if (_isAnswered) return;
    if (_isExamMode && !_ttsReady) return;

    if (_isExamMode) {
      _examTimer?.cancel();
      _examTimer = null;
      _timerBarController.stop();
      setState(() {
        _examTimerRemaining = null;
      });
    }

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (index == _correctShuffledIndex) {
        _score++;
      } else if (_isExamMode) {
        final q = _questions[_currentIndex];
        _examScore = (_examScore - q.pointsDeductionIfWrong).clamp(0, 50);
      }
    });

    if (_isExamMode) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _nextQuestion();
      });
    }
  }

  void _nextQuestion() {
    if (_isExamMode && _questions.isNotEmpty) {
      final q = _questions[_currentIndex];
      final correct = _selectedOptionIndex == _correctShuffledIndex;
      final selectedOriginal = _timedOutWithoutAnswer || _selectedOptionIndex == null
          ? null
          : (_shuffledIndices.length > _selectedOptionIndex!
              ? _shuffledIndices[_selectedOptionIndex!]
              : null);
      _questionResults.add(QuestionResult(
        questionSnapshot: q.toMap(),
        selectedOptionIndex: selectedOriginal,
        correct: correct,
        timedOut: _timedOutWithoutAnswer,
      ));
    }
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _resetQuestionState();
      });
      _prepareQuestionOptions();
      if (_isExamMode) _startTtsForCurrentQuestion();
    } else {
      _showResults();
    }
  }

  void _resetQuestionState() {
    _selectedOptionIndex = null;
    _isAnswered = false;
    _timedOutWithoutAnswer = false;
    if (_isExamMode) {
      _ttsReady = false;
      _examTimerRemaining = null;
      _examTimer?.cancel();
      _timerBarController.stop();
    }
  }

  Future<void> _showResults() async {
    final isExam = _isExamMode;
    final passed = isExam ? _examScore >= _passingScore : true;
    if (isExam && passed) {
      EnergyState().incrementPassedExams();
    }

    String? attemptId;
    if (isExam && _questionResults.length == _questions.length) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final attempt = ExamAttempt(
          userId: uid,
          completedAt: DateTime.now(),
          score: _examScore,
          passed: passed,
          questionResults: List.from(_questionResults),
        );
        attemptId = await ExamHistoryRepository.instance.saveAttempt(attempt);
      }
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.info_outline,
              size: 64,
              color: passed ? Colors.amber : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              isExam
                  ? (passed ? 'Geslaagd!' : 'Niet geslaagd')
                  : 'Gefeliciteerd!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isExam
                  ? 'Score: $_examScore / 50 (min. $_passingScore om te slagen)'
                  : 'Je score: $_score / ${_questions.length}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close sheet
                  context.pop(); // close quiz
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Terug naar overzicht'),
              ),
            ),
            if (isExam && attemptId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close sheet
                  context.pop(); // close quiz
                  context.push('/exam-review/$attemptId');
                },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Bekijk vragen'),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Oefenen')),
        body: const Center(child: Text('Geen vragen gevonden.')),
      );
    }

    final question = _questions[_currentIndex];
    final canTapAnswer = !_isExamMode || _ttsReady;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isExamMode
              ? '${(_examTimerRemaining ?? _examTimerSeconds) ~/ 60}:${((_examTimerRemaining ?? _examTimerSeconds) % 60).toString().padLeft(2, '0')}'
              : 'Oefenen',
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: _isExamMode
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Switch(
                        value: _ttsEnabled,
                        onChanged: (v) => setState(() => _ttsEnabled = v),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          // Top bar: exam = alleen tijd-cooldown (blauw); oefenen = vraagvoortgang
          _isExamMode
              ? (_examTimerRemaining != null
                  ? AnimatedBuilder(
                      animation: _timerBarController,
                      builder: (context, _) => LinearProgressIndicator(
                        value: 1.0 - _timerBarController.value,
                        backgroundColor: Colors.grey[200],
                        minHeight: 6,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                      ),
                    )
                  : LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: Colors.grey[200],
                      minHeight: 6,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ))
              : LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey[200],
                  minHeight: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                          fit: BoxFit
                              .contain, // or cover depending on aspect ratio
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
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
                  const SizedBox(height: 24),
                  // When timed out without answer: show message, do not highlight correct answer
                  if (_isAnswered && _timedOutWithoutAnswer) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
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
                    const SizedBox(height: 16),
                  ],
                  ...List.generate(
                    _shuffledOptions.isNotEmpty ? _shuffledOptions.length : question.options.length,
                    (index) {
                    final options = _shuffledOptions.isNotEmpty ? _shuffledOptions : question.options;
                    final correctIndex = _shuffledOptions.isNotEmpty ? _correctShuffledIndex : question.correctOptionIndex;
                    final isSelected = _selectedOptionIndex == index;
                    final isCorrect = index == correctIndex;
                    final hideCorrectAnswer = _timedOutWithoutAnswer;

                    // Determine color based on state (do not show correct/incorrect when timed out)
                    Color? backgroundColor;
                    Color textColor = Colors.black87;
                    Color borderColor = Colors.grey.shade300;

                    if (_isAnswered && !hideCorrectAnswer) {
                      if (isCorrect) {
                        backgroundColor = Colors.green.shade50;
                        borderColor = Colors.green;
                        textColor = Colors.green.shade900;
                      } else if (isSelected) {
                        backgroundColor = Colors.red.shade50;
                        borderColor = Colors.red;
                        textColor = Colors.red.shade900;
                      }
                    } else if (isSelected) {
                      borderColor = Theme.of(context).primaryColor;
                      backgroundColor =
                          Theme.of(context).primaryColor.withOpacity(0.05);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: canTapAnswer ? () => _handleAnswer(index) : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor ?? Colors.white,
                            border: Border.all(color: borderColor, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: borderColor,
                                  ),
                                ),
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isAnswered &&
                                            !hideCorrectAnswer &&
                                            (isCorrect || isSelected)
                                        ? borderColor
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (_isAnswered &&
                                  !hideCorrectAnswer &&
                                  isCorrect)
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                              if (_isAnswered &&
                                  !hideCorrectAnswer &&
                                  isSelected &&
                                  !isCorrect)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Explanation Card (not shown during exam)
                  if (_isAnswered && !_isExamMode) ...[
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
                              Icon(Icons.info_outline,
                                  size: 20, color: Colors.blue),
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
                ],
              ),
            ),
          ),
          // Knop hoger; vraagnummer onderaan
          if (_isAnswered && !_isExamMode)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: Colors.white,
              child: FilledButton(
                onPressed: _nextQuestion,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Volgende'
                      : 'Bekijk Resultaat',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          // Vraag X / Y helemaal onderaan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Colors.white,
            child: Center(
              child: Text(
                'Vraag ${_currentIndex + 1} / ${_questions.length}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
