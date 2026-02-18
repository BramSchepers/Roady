import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_models.dart';
import '../utils/onboarding_constants.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  static const _accentBlue = Color(0xFF2563EB);
  bool _ttsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isWideWeb = kIsWeb && MediaQuery.sizeOf(context).width >= kNarrowViewportMaxWidth;
    final bodyContent = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              const SizedBox(height: 24),
              Icon(Icons.school, size: 56, color: _accentBlue),
              const SizedBox(height: 16),
              Text(
                'Theorie-examen',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '50 vragen · zoals het echte examen in Vlaanderen. 15 seconden per vraag.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.volume_up, size: 22, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vraag voorlezen aanzetten voor het echte examen-gevoel',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                      ),
                    ),
                    Switch(
                      value: _ttsEnabled,
                      onChanged: (v) => setState(() => _ttsEnabled = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              isWideWeb
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: kWebButtonMaxWidth),
                        child: FilledButton(
                          onPressed: () => context.push('/quiz', extra: {
                            'mode': QuizMode.exam,
                            'ttsEnabled': _ttsEnabled,
                          }),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _accentBlue,
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          child: const Text('Examen starten'),
                        ),
                      ),
                    )
                  : FilledButton(
                      onPressed: () => context.push('/quiz', extra: {
                        'mode': QuizMode.exam,
                        'ttsEnabled': _ttsEnabled,
                      }),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _accentBlue,
                      ),
                      child: const Text('Examen starten'),
                    ),
              const SizedBox(height: 16),
              isWideWeb
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: kWebButtonMaxWidth),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => context.push('/exam-history'),
                            child: const Text('Examen historiek'),
                          ),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () => context.push('/exam-history'),
                      child: const Text('Examen historiek'),
                    ),
              const SizedBox(height: 24),
            ],
          ),
    );

    if (isWideWeb) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: SvgPicture.asset(
                  'assets/illustrations/Background_hero.svg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholderBuilder: (_) => const SizedBox.shrink(),
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: kWebContentMaxWidth),
                    child: ColoredBox(
                      color: Colors.white,
                      child: bodyContent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(child: bodyContent),
    );
  }
}
