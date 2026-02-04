import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/theory_models.dart';
import 'theory_player_screen.dart';

class TheoryScreen extends StatelessWidget {
  const TheoryScreen({super.key});

  final String _currentLang = 'nl'; // Hardcoded taal voor nu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // AppBar is niet per se nodig als het een tab is in Dashboard,
      // maar kan handig zijn voor de titel.
      appBar: AppBar(
        title: const Text('Theorie Overzicht'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyChapters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final chapter = dummyChapters[index];
          return _buildChapterCard(context, chapter);
        },
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, TheoryChapter chapter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior:
          Clip.antiAlias, // Zorgt dat plaatje binnen de ronding blijft
      child: InkWell(
        onTap: () {
          // Navigeer naar de speler
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TheoryPlayerScreen(chapter: chapter),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chapter Cover Image
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  // Achtergrond afbeelding
                  Positioned.fill(
                    child: SvgPicture.asset(
                      chapter.imageUrl,
                      fit: BoxFit.cover,
                      placeholderBuilder: (_) => Container(
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                  // Overlay voor betere leesbaarheid tekst
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Titel linksonder
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      chapter.getTitle(_currentLang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                    '${chapter.lessons.length} Lessen',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Spacer(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
