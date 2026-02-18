import 'package:flutter/foundation.dart';
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
    return widget.chapter.lessons.where((l) => completed.contains(l.id)).length;
  }

  bool get _isChapterComplete {
    return _completedCount() == widget.chapter.lessons.length;
  }

  /// Hardcoded: icoon per hoofdstuk (op id). Fallback op titel voor chapter_00/openbare weg.
  static IconData? _getChapterIcon(TheoryChapter chapter) {
    final id = chapter.id.toLowerCase();
    final titleNl = (chapter.title['nl'] ?? '').toLowerCase();

    // Op id
    switch (id) {
      case 'chapter_00':
        return Icons.menu_book_rounded;
      case 'chapter_01':
        return Icons.route_rounded;
      case 'chapter_02':
        return Icons.merge_type_rounded; // Rijstroken, busstrook, verdrijvingsvlak
      case 'chapter_03':
        return Icons.directions_bike_rounded; // Fietspad, oversteekplaats
      case 'chapter_04':
        return Icons.traffic_rounded; // Autosnelweg
      case 'chapter_05':
        return Icons.speed_rounded; // Autoweg, snelheid, verkeersborden
      case 'chapter_06':
        return Icons.home_work_rounded; // Bebouwde kom, zone, woonerf
      case 'chapter_07':
        return Icons.directions_walk_rounded; // Voetpad, oversteekplaats voetgangers
      case 'chapter_08':
        return Icons.drive_eta_rounded; // Bestuurders van motorvoertuigen
      case 'chapter_09':
        return Icons.build_circle_rounded; // M.T.M. en M.B.T. personenauto
      case 'chapter_10':
        return Icons.car_crash_rounded;
      case 'chapter_11':
        return Icons.warning_amber_rounded;
      case 'chapter_12':
        return Icons.lightbulb_rounded;
      case 'chapter_13':
        return Icons.electric_car_rounded;
      case 'chapter_14':
        return Icons.eco_rounded;
      case 'chapter_15':
        return Icons.assignment_rounded;
    }

    // Fallback op titel (oude/alternatieve documenten)
    if (titleNl == 'inleiding' || id == 'chapter_00') return Icons.menu_book_rounded;
    if (titleNl == 'openbare weg' || titleNl == 'de openbare weg') {
      return Icons.route_rounded;
    }
    return Icons.menu_book_rounded; // default voor onbekende hoofdstukken
  }

  /// Grotere afmetingen voor hoofdstuk-knoppen alleen op web.
  static double get _iconSize => kIsWeb ? 64 : 48;
  static double get _iconInnerSize => kIsWeb ? 36 : 28;
  static EdgeInsets get _headerPadding =>
      kIsWeb ? const EdgeInsets.fromLTRB(24, 20, 24, 16) : const EdgeInsets.fromLTRB(16, 16, 16, 12);
  static double get _titleFontSize => kIsWeb ? 22 : 18;
  static double get _progressFontSize => kIsWeb ? 16 : 14;
  static double get _expandIconSize => kIsWeb ? 32 : 28;
  static double get _lessonFontSize => kIsWeb ? 17 : 16;
  static double get _lessonIconSize => kIsWeb ? 24 : 22;
  static double get _lessonArrowSize => kIsWeb ? 14 : 12;

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
          constraints: kIsWeb
              ? const BoxConstraints(minHeight: 96)
              : null,
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
                      color: isComplete ? Colors.green.shade50 : Colors.white,
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
                    padding: _headerPadding,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Builder(
                            builder: (context) {
                              final chapterIcon =
                                  _getChapterIcon(widget.chapter);
                              return SizedBox(
                                width: _iconSize,
                                height: _iconSize,
                                child: chapterIcon != null
                                    ? Container(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.12),
                                        child: Icon(
                                          chapterIcon,
                                          size: _iconInnerSize,
                                          color:
                                              Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : CommonImage(
                                        imageUrl: widget.chapter.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: kIsWeb ? 16 : 12),
                        Expanded(
                          child: Text(
                            widget.chapter.getTitle(widget.currentLang),
                            style: TextStyle(
                              fontSize: _titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '$completed / $total',
                          style: TextStyle(
                            fontSize: _progressFontSize,
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
                            size: _expandIconSize,
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
                                      totalLessonsInApp:
                                          widget.totalLessonsInApp,
                                    ),
                                  ),
                                );
                                // Markeren doet de player (les gezien = groen vinkje, hoe ze ook sluiten).
                                final completed = result == true ||
                                    (result is Map &&
                                        result['completed'] == true);
                                final controllerValue = _controller.value;
                                if (completed && context.mounted) {
                                  setState(() {});
                                  widget.onChapterCompleted
                                      ?.call(widget.chapter);
                                  // Alleen accordion sluiten als alle lessen van dit hoofdstuk zijn bekeken
                                  if (_isChapterComplete &&
                                      controllerValue > 0) {
                                    _controller.reverse();
                                  }
                                } else if (completed && controllerValue > 0) {
                                  // context.mounted was false na pop: reverse in volgende frame
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (!mounted) return;
                                    setState(() {});
                                    widget.onChapterCompleted
                                        ?.call(widget.chapter);
                                    if (_isChapterComplete) {
                                      _controller.reverse();
                                    }
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
                                      size: _lessonIconSize,
                                      color: lessonDone
                                          ? Colors.green[600]
                                          : Colors.grey[400],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        lesson.getTitle(widget.currentLang),
                                        style: TextStyle(
                                          fontSize: _lessonFontSize,
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
                                      size: _lessonArrowSize,
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
