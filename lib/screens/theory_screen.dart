import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/theory_models.dart';
import '../models/energy_state.dart';
import '../repositories/theory_repository.dart';
import '../widgets/chapter_accordion.dart';
import '../debug_log_stub.dart' if (dart.library.io) '../debug_log_io.dart' as _log;

class TheoryScreen extends StatefulWidget {
  const TheoryScreen({super.key});

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  static const _currentLang = 'nl'; // Hardcoded taal voor nu

  List<TheoryChapter>? _chapters;
  void Function()? _completedListener;

  @override
  void initState() {
    super.initState();
    _completedListener = () => setState(() {});
    EnergyState().completedLessons.addListener(_completedListener!);
    TheoryRepository.instance.getChapters().then((c) {
      // #region agent log
      _log.debugLog('theory_screen.dart', 'getChapters then', {
        'mounted': mounted,
        'listLength': c.length,
        'firstChapterId': c.isNotEmpty ? c.first.id : null,
        'source': c.isNotEmpty && c.first.id == 'chapter_00' ? 'likely_firestore' : 'likely_dummy',
      }, 'E');
      // #endregion
      if (mounted) setState(() => _chapters = c);
    });
  }

  @override
  void dispose() {
    EnergyState().completedLessons.removeListener(_completedListener!);
    super.dispose();
  }

  int _totalLessonsInApp(List<TheoryChapter> chapters) {
    int total = 0;
    for (var c in chapters) {
      total += c.lessons.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters ?? dummyChapters;
    final totalLessons = _totalLessonsInApp(chapters);

    return Scaffold(
      backgroundColor: Colors.white,
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
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ColoredBox(
                    color: Colors.white,
                    child: _chapters == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: chapters.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          return ChapterAccordion(
                            chapter: chapter,
                            currentLang: _currentLang,
                            totalLessonsInApp: totalLessons,
                            onChapterCompleted: (c) =>
                                _showCompletionAnimation(context, c),
                          );
                        },
                      ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
