import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../repositories/theory_repository.dart';
import '../widgets/onboarding_page_indicator.dart';

class OfflineDownloadScreen extends StatefulWidget {
  const OfflineDownloadScreen({super.key});

  @override
  State<OfflineDownloadScreen> createState() => _OfflineDownloadScreenState();
}

class _OfflineDownloadScreenState extends State<OfflineDownloadScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = '';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Content ophalen...';
      _progress = 0.0;
    });

    try {
      // 1. Haal alle hoofdstukken op
      final chapters = await TheoryRepository.instance.getChapters();

      // 2. Verzamel alle URLs
      final Set<String> urlsToDownload = {};

      for (var chapter in chapters) {
        if (chapter.imageUrl.startsWith('http')) {
          urlsToDownload.add(chapter.imageUrl);
        }

        for (var lesson in chapter.lessons) {
          if (lesson.imageUrl != null && lesson.imageUrl!.startsWith('http')) {
            urlsToDownload.add(lesson.imageUrl!);
          }
        }
      }

      if (urlsToDownload.isEmpty) {
        _finish();
        return;
      }

      // 3. Downloaden
      int completed = 0;
      int total = urlsToDownload.length;

      for (String url in urlsToDownload) {
        try {
          await DefaultCacheManager().getSingleFile(url);
        } catch (e) {
          debugPrint('Fout bij downloaden van $url: $e');
          // Doorgaan met de rest
        }

        completed++;
        if (mounted) {
          setState(() {
            _progress = completed / total;
            _statusText = 'Downloaden: ${((completed / total) * 100).toInt()}%';
          });
        }
      }

      _finish();
    } catch (e) {
      debugPrint('Fout tijdens download proces: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Er ging iets mis bij het downloaden.')),
        );
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _finish() {
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    const accentBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Achtergrond
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/region'),
                      color: accentBlue,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      'assets/images/logo-roady.png',
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('Roady',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: accentBlue)),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Offline leren',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wil je alle afbeeldingen alvast downloaden? Zo kun je ook zonder internet studeren en werkt de app sneller.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[900],
                          height: 1.5,
                        ),
                  ),
                  const Spacer(),
                  const Center(
                    child: OnboardingPageIndicator(
                      currentIndex: 3,
                      totalSteps: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isDownloading) ...[
                    Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[200],
                      color: accentBlue,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    FilledButton.icon(
                      onPressed: _startDownload,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text(
                        'Download alles',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Overslaan',
                        style: TextStyle(
                          color: Colors.grey[900],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
