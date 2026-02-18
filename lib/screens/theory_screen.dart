import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/theory_models.dart';
import '../models/energy_state.dart';
import '../repositories/theory_repository.dart';
import '../utils/onboarding_constants.dart';
import '../utils/theory_groups.dart';
import '../widgets/chapter_accordion.dart';
import '../widgets/theory_group_card.dart';

class TheoryScreen extends StatefulWidget {
  const TheoryScreen({super.key});

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  static const _currentLang = 'nl'; // Hardcoded taal voor nu

  List<TheoryChapter>? _chapters;
  void Function()? _completedListener;

  /// null = toon overzicht van 6 groepen; 0..5 = toon hoofdstukken van die groep
  int? _selectedGroupIndex;

  @override
  void initState() {
    super.initState();
    _completedListener = () => setState(() {});
    EnergyState().completedLessons.addListener(_completedListener!);
    TheoryRepository.instance.getChapters().then((c) {
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

  /// Hoofdstukken voor de geselecteerde groep, in de volgorde van theoryGroups.
  List<TheoryChapter> _chaptersForGroup(int groupIndex) {
    final chapters = _chapters ?? [];
    final group = theoryGroups[groupIndex];
    final result = <TheoryChapter>[];
    for (final id in group.chapterIds) {
      final ch = chapters.where((c) => c.id == id).firstOrNull;
      if (ch != null) result.add(ch);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters ?? [];
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
                  constraints: BoxConstraints(
                    maxWidth: kIsWeb
                        ? kWebNavContentMaxWidth
                        : 420,
                  ),
                  child: ColoredBox(
                    color: Colors.white,
                    child: _chapters == null
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _selectedGroupIndex != null
                            ? _buildGroupChaptersView(
                                context,
                                totalLessons,
                              )
                            : _buildGroupsOverview(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Overzicht van 6 groepen: web = grid max 4 kolommen, mobiel = lijst onder elkaar.
  Widget _buildGroupsOverview(BuildContext context) {
    if (kIsWeb) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width > 800 ? 4 : (width > 500 ? 3 : 2);
          return GridView.builder(
            padding: const EdgeInsets.all(28),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.78,
              crossAxisSpacing: 28,
              mainAxisSpacing: 28,
            ),
            itemCount: theoryGroups.length,
            itemBuilder: (context, index) {
              return TheoryGroupCard(
                group: theoryGroups[index],
                onStart: () => setState(() => _selectedGroupIndex = index),
              );
            },
          );
        },
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: theoryGroups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return TheoryGroupCard(
          group: theoryGroups[index],
          onStart: () => setState(() => _selectedGroupIndex = index),
        );
      },
    );
  }

  /// Lijst van hoofdstukken van de geselecteerde groep + terugknop.
  Widget _buildGroupChaptersView(
    BuildContext context,
    int totalLessonsInApp,
  ) {
    final groupChapters = _chaptersForGroup(_selectedGroupIndex!);
    final group = theoryGroups[_selectedGroupIndex!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selectedGroupIndex = null),
              ),
              Expanded(
                child: Text(
                  group.title,
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
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: groupChapters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final chapter = groupChapters[index];
              return ChapterAccordion(
                key: ValueKey(chapter.id),
                chapter: chapter,
                currentLang: _currentLang,
                totalLessonsInApp: totalLessonsInApp,
                onChapterCompleted: (c) => _showCompletionAnimation(context, c),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCompletionAnimation(BuildContext context, TheoryChapter chapter) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: CompletionAnimationWidget(
          onComplete: () {
            overlayEntry.remove();
          },
        ),
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
    // Use LayoutBuilder so centering uses actual overlay size (fixes web where
    // overlay may not report full viewport via MediaQuery).
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final startX = width / 2;
        final startY = height / 2;

        // Op web: animatie naar logo in nav (linksboven); op mobiel naar FAB (midden onder)
        final double endX;
        final double endY;
        if (kIsWeb) {
          final sideMargin = (width * 0.12).clamp(24.0, 200.0);
          // Logo: 4px padding + beeld (ca. 80px breed) → midden ≈ sideMargin + 4 + 40
          endX = sideMargin + 44;
          endY = 28; // midden van AppBar
        } else {
          endX = width / 2;
          endY = height - 50;
        }

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
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.check, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
