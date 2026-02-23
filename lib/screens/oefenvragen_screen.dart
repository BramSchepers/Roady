import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_models.dart';
import '../utils/onboarding_constants.dart';

class OefenvragenScreen extends StatelessWidget {
  const OefenvragenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWideWeb =
        kIsWeb && MediaQuery.sizeOf(context).width >= kNarrowViewportMaxWidth;

    final List<Widget> cardList = [
      _QuizSelectionCard(
        title: 'Verkeersborden',
        description: 'Oefen specifiek op borden en hun betekenis.',
        color: Colors.blue,
        icon: Icons.traffic,
        onTap: () => context.push('/quiz', extra: QuizMode.trafficSigns),
      ),
      _QuizSelectionCard(
        title: 'Per Hoofdstuk',
        description: 'Toets je kennis per onderwerp.',
        icon: Icons.menu_book,
        color: Colors.orange,
        onTap: () => context.push('/quiz', extra: QuizMode.chapter),
      ),
      _QuizSelectionCard(
        title: 'Willekeurig',
        description: 'Een mix van alle soorten vragen.',
        icon: Icons.shuffle,
        color: Colors.purple,
        onTap: () => context.push('/quiz', extra: QuizMode.random),
      ),
      _QuizSelectionCard(
        title: 'Zware overtredingen',
        description: 'Oefen enkel de zware overtredingen',
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
        onTap: () => context.push('/quiz', extra: QuizMode.random),
      ),
    ];

    // Web: titel + ondertitel gecentreerd, 4 categorieën onder elkaar en gecentreerd
    const double cardWidth = 700;
    final Widget webContent = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Oefenen',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kies een categorie om te starten',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 32),
          ...cardList.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: cardWidth,
                height: 110,
                child: c,
              ),
            ),
          ),
        ],
      ),
    );

    // Mobiel: volledige content (titel + knoppen onder elkaar)
    final Widget mobileContent = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Oefenen',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kies een categorie om te starten',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 32),
          ...cardList.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: c,
              )),
        ],
      ),
    );

    if (isWideWeb) {
      // Witte balk over volledige hoogte (van boven tot beneden), inhoud scrollt erbinnen
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
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
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final w = constraints.maxWidth;
                  const topMargin = 10.0; // marge boven witte balk (alleen web)
                  const radius = 32.0; // boxing radius bovenhoeken (alleen web)
                  final barWidth =
                      (w - 40).clamp(0.0, kWebNavContentMaxWidth.toDouble());
                  return Padding(
                    padding: const EdgeInsets.only(top: topMargin),
                    child: SizedBox(
                      width: w,
                      height: h - topMargin,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: barWidth,
                            height: h - topMargin,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(radius),
                                topRight: Radius.circular(radius),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: webContent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: mobileContent),
    );
  }
}

class _QuizSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const _QuizSelectionCard({
    required this.title,
    required this.description,
    this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon ?? Icons.traffic,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
