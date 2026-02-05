import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/theory_models.dart';

class TheoryPlayerScreen extends StatefulWidget {
  final TheoryChapter chapter;

  const TheoryPlayerScreen({
    super.key,
    required this.chapter,
  });

  @override
  State<TheoryPlayerScreen> createState() => _TheoryPlayerScreenState();
}

class _TheoryPlayerScreenState extends State<TheoryPlayerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Hardcoded taal voor nu
  final String _currentLang = 'nl';

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
                setState(() {
                  _currentPage = index;
                });
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
                    onPressed: () {
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
                    onPressed: () {
                      // Klaar met module
                      Navigator.of(context).pop(
                          true); // Ga terug naar overzicht en start animatie
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
          // 1. Animatie / Afbeelding
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50], // Lichte achtergrond voor animatie
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
