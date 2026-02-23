import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import '../models/theory_models.dart';
import '../models/energy_state.dart';
import '../widgets/image_loading_placeholder.dart';

class TheoryPlayerScreen extends StatefulWidget {
  final TheoryChapter chapter;
  final int initialPage;
  final int totalLessonsInApp;

  const TheoryPlayerScreen({
    super.key,
    required this.chapter,
    this.initialPage = 0,
    required this.totalLessonsInApp,
  });

  @override
  State<TheoryPlayerScreen> createState() => _TheoryPlayerScreenState();
}

class _TheoryPlayerScreenState extends State<TheoryPlayerScreen> {
  late DateTime _startTime;
  late final PageController _pageController;

  /// Alleen bijgewerkt door initState en Volgende/Vorige (niet door onPageChanged: die geeft spurious index).
  late int _currentPage;

  final String _currentLang = 'nl';

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _pageController = PageController(initialPage: widget.initialPage);
    _currentPage = widget.initialPage;
    _markLessonComplete(widget.initialPage);
    EnergyState().savePendingViewedLessonId(
        widget.chapter.lessons[widget.initialPage].id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _preloadAdjacentImages(_currentPage);
    });
  }

  Future<void> _markLessonComplete(int index) async {
    if (index < 0 || index >= widget.chapter.lessons.length) return;
    final lesson = widget.chapter.lessons[index];
    final amount =
        widget.totalLessonsInApp > 0 ? 1.0 / widget.totalLessonsInApp : 0.0;
    await EnergyState().addProgress(amount, lessonId: lesson.id);
  }

  /// Bij sluiten (X of back): les die nu zichtbaar is markeren, pending clearen, pop.
  Future<void> _leaveAndMarkCurrent() async {
    // Gebruik de actuele positie van de PageController als bron van waarheid
    int index = _currentPage;
    if (_pageController.hasClients && _pageController.page != null) {
      index = _pageController.page!.round();
    }

    // Zorg dat index binnen bereik is
    index = index.clamp(0, widget.chapter.lessons.length - 1);

    await _markLessonComplete(index);
    await EnergyState().clearPendingViewedLessonId();
    if (!mounted) return;
    Navigator.of(context).pop(<String, dynamic>{
      'completed': true,
      'completedLessonIndex': index,
    });
  }

  void _preloadAdjacentImages(int currentIndex) {
    for (final offset in [1, -1]) {
      final index = currentIndex + offset;
      if (index < 0 || index >= widget.chapter.lessons.length) continue;
      final url = widget.chapter.lessons[index].effectiveImageUrl;
      if (url != null &&
          url.isNotEmpty &&
          (url.startsWith('http://') || url.startsWith('https://'))) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _leaveAndMarkCurrent();
      },
      child: Scaffold(
        backgroundColor: kIsWeb ? Colors.white : Colors.grey[50],
        appBar: AppBar(
          title: Text(widget.chapter.getTitle(_currentLang)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _leaveAndMarkCurrent(),
          ),
        ),
        body: Stack(
          children: [
            // SVG achtergrond zichtbaar aan de buitenste randen
            Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/background.webp',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            // Content met ~1/4 marge links/rechts op web
            SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb
                        ? MediaQuery.sizeOf(context).width * 0.25
                        : 0,
                  ),
                  child: Column(
                    children: [
                      // Voortgangsindicator
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / widget.chapter.lessons.length,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF2563EB), // Roady blauw
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.chapter.lessons.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);

                            // Sla pending op als de app crasht, maar negeer snelle spurious events bij start (<500ms)
                            if (DateTime.now().difference(_startTime).inMilliseconds >
                                500) {
                              if (index < widget.chapter.lessons.length) {
                                EnergyState().savePendingViewedLessonId(
                                    widget.chapter.lessons[index].id);
                              }
                            }

                            _preloadAdjacentImages(index);
                          },
                          itemBuilder: (context, index) {
                            final lesson = widget.chapter.lessons[index];
                            return _buildLessonCard(context, lesson);
                          },
                        ),
                      ),

                      // Navigatie knoppen
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentPage > 0)
                              TextButton.icon(
                                onPressed: () async {
                                  await _markLessonComplete(_currentPage);
                                  if (!mounted) return;
                                  setState(() => _currentPage--);
                                  EnergyState().savePendingViewedLessonId(
                                      widget.chapter.lessons[_currentPage].id);
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Vorige'),
                              )
                            else
                              const SizedBox(width: 100), // Spacer

                            Text(
                              '${_currentPage + 1} / ${widget.chapter.lessons.length}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (_currentPage < widget.chapter.lessons.length - 1)
                              FilledButton.icon(
                                onPressed: () async {
                                  await _markLessonComplete(_currentPage);
                                  if (!mounted) return;
                                  setState(() => _currentPage++);
                                  EnergyState().savePendingViewedLessonId(
                                      widget.chapter.lessons[_currentPage].id);
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                ),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Volgende'),
                              )
                            else
                              FilledButton.icon(
                                onPressed: () => _leaveAndMarkCurrent(),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Afronden'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonMedia(TheoryLesson lesson) {
    final imageUrl = lesson.effectiveImageUrl;
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Padding(
          padding: EdgeInsets.all(24.0),
          child: ImageLoadingPlaceholder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        errorWidget: (context, url, error) => Padding(
          padding: const EdgeInsets.all(24),
          child: DotLottieLoader.fromAsset(
            lesson.lottieAsset,
            frameBuilder: (BuildContext context, dotlottie) {
              if (dotlottie != null && dotlottie.animations.isNotEmpty) {
                return Lottie.memory(
                  dotlottie.animations.values.first,
                  fit: BoxFit.contain,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: DotLottieLoader.fromAsset(
        lesson.lottieAsset,
        frameBuilder: (BuildContext context, dotlottie) {
          if (dotlottie != null && dotlottie.animations.isNotEmpty) {
            return Lottie.memory(
              dotlottie.animations.values.first,
              fit: BoxFit.contain,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, TheoryLesson lesson) {
    final isMobile = !kIsWeb;
    final titleFontSize = isMobile ? 22.0 : 27.0;
    final bodyFontSize = isMobile ? 16.0 : 18.0;
    final h1FontSize = isMobile ? 19.0 : 22.0;
    final h2FontSize = isMobile ? 18.0 : 20.0;
    final h3FontSize = isMobile ? 17.0 : 19.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Afbeelding: container evengroot als foto (vaste aspectratio, geen lege ruimte)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildLessonMedia(lesson),
            ),
          ),

          // 2. Tekst Content (direct onder de foto)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.getTitle(_currentLang),
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MarkdownBody(
                      data: lesson.getDescription(_currentLang),
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                          height: 1.6,
                        ),
                        strong: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.grey[900],
                          fontWeight: FontWeight.bold,
                          height: 1.6,
                        ),
                        em: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.grey[800],
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                        listIndent: 24,
                        listBullet: TextStyle(
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                          height: 1.6,
                        ),
                        h1: TextStyle(
                          fontSize: h1FontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          height: 1.3,
                        ),
                        h2: TextStyle(
                          fontSize: h2FontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          height: 1.3,
                        ),
                        h3: TextStyle(
                          fontSize: h3FontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
