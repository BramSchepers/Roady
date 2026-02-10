import 'package:flutter/material.dart';
import '../models/theory_models.dart';
import '../models/energy_state.dart';
import '../widgets/common_image.dart';
import '../screens/theory_player_screen.dart';

class ChapterAccordion extends StatefulWidget {
  final TheoryChapter chapter;
  final String currentLang;
  final int totalLessonsInApp;
  final void Function(TheoryChapter)? onChapterCompleted;

  const ChapterAccordion({
    super.key,
    required this.chapter,
    required this.currentLang,
    required this.totalLessonsInApp,
    this.onChapterCompleted,
  });

  @override
  State<ChapterAccordion> createState() => _ChapterAccordionState();
}

class _ChapterAccordionState extends State<ChapterAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _completedCount() {
    final completed = EnergyState().completedLessons.value;
    return widget.chapter.lessons
        .where((l) => completed.contains(l.id))
        .length;
  }

  bool get _isChapterComplete {
    return _completedCount() == widget.chapter.lessons.length;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completedCount();
    final total = widget.chapter.lessons.length;
    final isComplete = _isChapterComplete;

    return ValueListenableBuilder<List<String>>(
      valueListenable: EnergyState().completedLessons,
      builder: (context, completedIds, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: isComplete
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                )
              : null,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (_controller.isCompleted) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? Colors.green.shade50
                        : Colors.white,
                    boxShadow: isComplete
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CommonImage(
                            imageUrl: widget.chapter.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.chapter.getTitle(widget.currentLang),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '$completed / $total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _controller.value * 0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: Icon(
                          Icons.expand_more,
                          size: 28,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.chapter.lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final lesson = widget.chapter.lessons[index];
                        final lessonDone = completedIds.contains(lesson.id);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TheoryPlayerScreen(
                                    chapter: widget.chapter,
                                    initialPage: index,
                                    totalLessonsInApp: widget.totalLessonsInApp,
                                  ),
                                ),
                              );
                              // Markeren doet de player (les gezien = groen vinkje, hoe ze ook sluiten).
                              final completed = result == true ||
                                  (result is Map && result['completed'] == true);
                              final completedIndex = result is Map
                                  ? result['completedLessonIndex'] as int?
                                  : null;
                              final lastIndex = widget.chapter.lessons.length - 1;
                              final wasLastLesson = completedIndex != null &&
                                  completedIndex == lastIndex;
                              final controllerValue = _controller.value;
                              if (completed && context.mounted) {
                                setState(() {});
                                widget.onChapterCompleted?.call(widget.chapter);
                                if (wasLastLesson && controllerValue > 0) {
                                  _controller.reverse();
                                }
                              } else if (completed && wasLastLesson && controllerValue > 0) {
                                // context.mounted was false na pop: reverse in volgende frame
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (!mounted) return;
                                  setState(() {});
                                  widget.onChapterCompleted?.call(widget.chapter);
                                  _controller.reverse();
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    lessonDone
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 22,
                                    color: lessonDone
                                        ? Colors.green[600]
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      lesson.getTitle(widget.currentLang),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: lessonDone
                                            ? Colors.grey[600]
                                            : Colors.black87,
                                        fontWeight: lessonDone
                                            ? FontWeight.w500
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}
