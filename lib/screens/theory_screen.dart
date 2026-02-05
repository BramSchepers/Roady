import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/theory_models.dart';
import '../models/energy_state.dart';
import '../widgets/common_image.dart';
import 'theory_player_screen.dart';

class TheoryScreen extends StatefulWidget {
  const TheoryScreen({super.key});

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  static const _heroBg = Color(0xFFe8f0e9);
  static const _currentLang = 'nl'; // Hardcoded taal voor nu

  final Set<String> _completedIds = {};
  void Function()? _completedListener;

  @override
  void initState() {
    super.initState();
    _completedListener = () => setState(() {});
    EnergyState().completedLessons.addListener(_completedListener!);
  }

  @override
  void dispose() {
    EnergyState().completedLessons.removeListener(_completedListener!);
    super.dispose();
  }

  bool _isCompleted(TheoryChapter chapter) {
    return _completedIds.contains(chapter.id) ||
        EnergyState().completedLessons.value.contains(chapter.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _heroBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: _heroBg,
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: dummyChapters.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final chapter = dummyChapters[index];
                  return _buildChapterCard(context, chapter);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, TheoryChapter chapter) {
    final completed = _isCompleted(chapter);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior:
          Clip.antiAlias, // Zorgt dat plaatje binnen de ronding blijft
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TheoryPlayerScreen(chapter: chapter),
            ),
          );

          if (result == true && context.mounted) {
            setState(() => _completedIds.add(chapter.id));
            _showCompletionAnimation(context, chapter);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bovenkant: klein icoon + titel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CommonImage(
                        imageUrl: chapter.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chapter.getTitle(_currentLang),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer met info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.class_outlined,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${chapter.lessons.length} pagina\'s',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  if (completed) ...[
                    Text(
                      'Voltooid',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.green[600],
                    ),
                  ] else ...[
                    Text(
                      'Starten',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionAnimation(BuildContext context, TheoryChapter chapter) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CompletionAnimationWidget(
        onComplete: () {
          overlayEntry.remove();

          // Bereken voortgang op basis van het aantal lessen in dit hoofdstuk
          // vs totaal aantal lessen in de hele app.
          int totalLessonsInApp = 0;
          for (var c in dummyChapters) {
            totalLessonsInApp += c.lessons.length;
          }

          if (totalLessonsInApp > 0) {
            final double progressPerLesson = 1.0 / totalLessonsInApp;
            final double chapterProgress =
                progressPerLesson * chapter.lessons.length;

            EnergyState().addProgress(chapterProgress, lessonId: chapter.id);
          }
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class CompletionAnimationWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const CompletionAnimationWidget({super.key, required this.onComplete});

  @override
  State<CompletionAnimationWidget> createState() =>
      _CompletionAnimationWidgetState();
}

class _CompletionAnimationWidgetState extends State<CompletionAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1. Verschijn en puls (0 - 40%)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 0.4)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 60),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0),
    ));

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final startX = size.width / 2;
    final startY = size.height / 2;

    // Target FAB position (bottom center)
    final endX = size.width / 2;
    final endY = size.height - 50;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double moveProgress = 0.0;
        if (_controller.value > 0.4) {
          moveProgress = (_controller.value - 0.4) / 0.6;
          moveProgress = Curves.easeInOutCubic.transform(moveProgress);
        }

        final currentX = startX + (endX - startX) * moveProgress;
        final currentY = startY + (endY - startY) * moveProgress;

        return Stack(
          children: [
            Positioned(
              left: currentX - 50,
              top: currentY - 50,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                        stops: [0.3, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
