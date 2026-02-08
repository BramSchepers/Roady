import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
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
  late final PageController _pageController;
  late int _currentPage;

  // Hardcoded taal voor nu
  final String _currentLang = 'nl';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _currentPage = widget.initialPage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _preloadAdjacentImages(_currentPage);
    });
  }

  Future<void> _markLessonComplete(int index) async {
    if (index < 0 || index >= widget.chapter.lessons.length) return;
    final lesson = widget.chapter.lessons[index];
    final amount = widget.totalLessonsInApp > 0
        ? 1.0 / widget.totalLessonsInApp
        : 0.0;
    await EnergyState().addProgress(amount, lessonId: lesson.id);
  }

  void _preloadAdjacentImages(int currentIndex) {
    for (final offset in [1, -1]) {
      final index = currentIndex + offset;
      if (index < 0 || index >= widget.chapter.lessons.length) continue;
      final url = widget.chapter.lessons[index].imageUrl;
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.chapter.getTitle(_currentLang)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
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

          // Swipeable Kaarten
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.chapter.lessons.length,
              onPageChanged: (index) {
                final previousPage = _currentPage;
                setState(() {
                  _currentPage = index;
                });
                if (index > previousPage) {
                  _markLessonComplete(previousPage);
                }
                _preloadAdjacentImages(index);
              },
              itemBuilder: (context, index) {
                final lesson = widget.chapter.lessons[index];
                return _buildLessonCard(lesson);
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
                    onPressed: () {
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
                    onPressed: () async {
                      await _markLessonComplete(_currentPage);
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                    },
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
    );
  }

  Widget _buildLessonMedia(TheoryLesson lesson) {
    final imageUrl = lesson.imageUrl;
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
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

  Widget _buildLessonCard(TheoryLesson lesson) {
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
          // 1. Afbeelding (als URL) of animatie / Lottie
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildLessonMedia(lesson),
            ),
          ),

          // 2. Tekst Content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.getTitle(_currentLang),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.getDescription(_currentLang),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.6,
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
