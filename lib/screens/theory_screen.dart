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
    // Toon eerst cache (snel), haal daarna verse lessen van server en update UI
    TheoryRepository.instance.getChapters().then((c) {
      if (mounted) setState(() => _chapters = c);
    });
    TheoryRepository.instance.refreshChaptersFromServer().then((c) {
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

  /// Aantal voltooide en totaal aantal lessen voor één groep (categorie).
  ({int completed, int total}) _groupProgress(int groupIndex) {
    final groupChapters = _chaptersForGroup(groupIndex);
    int total = 0;
    int completed = 0;
    final completedIds = EnergyState().completedLessons.value;
    for (final ch in groupChapters) {
      for (final lesson in ch.lessons) {
        total++;
        if (completedIds.contains(lesson.id)) completed++;
      }
    }
    return (completed: completed, total: total);
  }

  bool _isGroupComplete(int groupIndex) {
    final p = _groupProgress(groupIndex);
    return p.total > 0 && p.completed == p.total;
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
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: kIsWeb
                          ? kWebNavContentMaxWidth
                          : 420,
                    ),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _refreshChapters() async {
    final c = await TheoryRepository.instance.refreshChaptersFromServer();
    if (mounted) setState(() => _chapters = c);
  }

  /// Overzicht van 6 groepen: web = grid max 4 kolommen, mobiel = lijst onder elkaar.
  Widget _buildGroupsOverview(BuildContext context) {
    if (kIsWeb) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width > 800 ? 4 : (width > 500 ? 3 : 2);
          return RefreshIndicator(
            onRefresh: _refreshChapters,
            child: GridView.builder(
              padding: const EdgeInsets.all(28),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.78,
                crossAxisSpacing: 28,
                mainAxisSpacing: 28,
              ),
              itemCount: theoryGroups.length,
              itemBuilder: (context, index) {
                final progress = _groupProgress(index);
                return TheoryGroupCard(
                  group: theoryGroups[index],
                  onStart: () => setState(() => _selectedGroupIndex = index),
                  completedCount: progress.completed,
                  totalCount: progress.total,
                );
              },
            ),
          );
        },
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshChapters,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: theoryGroups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final progress = _groupProgress(index);
          return TheoryGroupCard(
            group: theoryGroups[index],
            onStart: () => setState(() => _selectedGroupIndex = index),
            completedCount: progress.completed,
            totalCount: progress.total,
          );
        },
      ),
    );
  }

  /// Lijst van hoofdstukken van de geselecteerde groep + terugknop.
  Widget _buildGroupChaptersView(
    BuildContext context,
    int totalLessonsInApp,
  ) {
    final groupChapters = _chaptersForGroup(_selectedGroupIndex!);
    final group = theoryGroups[_selectedGroupIndex!];
    final isGroupComplete = _isGroupComplete(_selectedGroupIndex!);

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
        if (isGroupComplete)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Material(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.green.shade800,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Categorie voltooid!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Je hebt alle lessen van deze categorie doorlopen.',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: groupChapters.isEmpty
              ? _buildEmptyGroupState(context)
              : RefreshIndicator(
                  onRefresh: _refreshChapters,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: groupChapters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final chapter = groupChapters[index];
                      return ChapterAccordion(
                        key: ValueKey(chapter.id),
                        chapter: chapter,
                        currentLang: _currentLang,
                        totalLessonsInApp: totalLessonsInApp,
                        onChapterCompleted: (c) =>
                            _showCompletionAnimation(context, c),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  /// Toont een duidelijke melding + vernieuwknop als er geen lessen in deze categorie zijn.
  Widget _buildEmptyGroupState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Geen lessen beschikbaar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Controleer je internet en trek omlaag om te vernieuwen, of wacht even tot de inhoud is geladen.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _refreshChapters,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Vernieuwen'),
              ),
            ],
          ),
        ),
      ),
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
