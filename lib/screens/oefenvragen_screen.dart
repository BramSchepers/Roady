import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_models.dart';
import '../repositories/saved_questions_repository.dart';
import '../services/revenuecat_service.dart';
import '../utils/onboarding_constants.dart';

class OefenvragenScreen extends StatefulWidget {
  const OefenvragenScreen({super.key});

  @override
  State<OefenvragenScreen> createState() => _OefenvragenScreenState();
}

class _OefenvragenScreenState extends State<OefenvragenScreen> {
  bool _isPro = false;
  bool _proLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProStatus();
  }

  Future<void> _loadProStatus() async {
    if (!RevenueCatService.isSupported) {
      if (mounted) {
        setState(() => _proLoaded = true);
      }
      return;
    }
    try {
      final isPro = await RevenueCatService.instance.hasProEntitlement();
      if (mounted) {
        setState(() {
          _isPro = isPro;
          _proLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _proLoaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideWeb =
        kIsWeb && MediaQuery.sizeOf(context).width >= kNarrowViewportMaxWidth;
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous == true;
    final isPro = _isPro;

    final List<Widget> cardList = [
      _QuizSelectionCard(
        title: 'Willekeurig',
        description: 'Een mix van alle soorten vragen.',
        icon: Icons.shuffle,
        color: Colors.purple,
        onTap: () => _onCategorySelected(context, QuizMode.random),
        enabled: !isGuest,
      ),
      _QuizSelectionCard(
        title: 'Verkeersborden',
        description: 'Oefen specifiek op borden en hun betekenis.',
        color: Colors.blue,
        customIcon: _TrafficSignC43Icon(color: Colors.blue),
        onTap: () => _onCategorySelected(context, QuizMode.trafficSigns),
        enabled: !isGuest && isPro,
      ),
      _QuizSelectionCard(
        title: 'Per Hoofdstuk',
        description: 'Toets je kennis per onderwerp.',
        icon: Icons.menu_book,
        color: Colors.orange,
        onTap: () => _onCategorySelected(context, QuizMode.chapter),
        enabled: !isGuest && isPro,
      ),
      _QuizSelectionCard(
        title: 'Zware overtredingen',
        description: 'Oefen enkel de zware overtredingen',
        icon: Icons.warning_amber_rounded,
        color: Colors.red,
        onTap: () => _onCategorySelected(context, QuizMode.random),
        enabled: !isGuest && isPro,
      ),
      _QuizSelectionCard(
        title: 'Opgeslagen oefenvragen',
        description: 'Oefen opnieuw met vragen die je hebt opgeslagen.',
        icon: Icons.bookmark,
        color: Colors.teal,
        onTap: () async {
          final ids =
              await SavedQuestionsRepository.instance.getSavedQuestionIds();
          if (!context.mounted) return;
          if (ids.isNotEmpty) {
            // Gebruik een vaste limiet op basis van Pro / niet-Pro, maar toon geen selector hier.
            final questionLimit = isPro ? 20 : 5;
            context.push(
              '/quiz',
              extra: {
                'mode': QuizMode.random,
                'savedQuestionIds': ids,
                'questionLimit': questionLimit,
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Nog geen opgeslagen vragen. Sla tijdens het oefenen vragen op met het bookmark-icoon.',
                ),
              ),
            );
          }
        },
        enabled: !isGuest && isPro,
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
          if (isGuest) ...[
            const SizedBox(height: 8),
            Text(
              'Maak een account om te oefenen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ] else if (!isGuest && !isPro && _proLoaded) ...[
            const SizedBox(height: 8),
            Text(
              'Upgrade naar Roady Pro om alle oefenvragen vrij te spelen. '
              'Als niet‑Pro kun je alleen willekeurige vragen oefenen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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
          if (isGuest) ...[
            const SizedBox(height: 8),
            Text(
              'Maak een account om te oefenen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ] else if (!isGuest && !isPro && _proLoaded) ...[
            const SizedBox(height: 8),
            Text(
              'Upgrade naar Roady Pro om alle oefenvragen vrij te spelen. '
              'Als niet‑Pro kun je alleen willekeurige vragen oefenen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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

  /// Toont een simpele vraag-selector (5 / 10 / 20) en navigeert daarna naar de quiz.
  Future<void> _onCategorySelected(BuildContext context, QuizMode mode) async {
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous == true;
    final isPro = _isPro;

    // Alleen ingelogde gebruikers mogen hier komen; gasten zijn al uitgegrijsd.
    if (isGuest) return;

    final bool isRandomMode = mode == QuizMode.random;

    // Niet-Pro en geen willekeurig: zouden al disabled moeten zijn.
    if (!isPro && !isRandomMode) return;

    final bool isRandomNonPro = !isPro && isRandomMode;

    final bool useCenterDialog = kIsWeb &&
        MediaQuery.sizeOf(context).width >= kNarrowViewportMaxWidth;

    final int? selected = useCenterDialog
        ? await showDialog<int>(
            context: context,
            builder: (ctx) => Dialog(
              child: _QuestionCountContent(
                isRandomNonPro: isRandomNonPro,
                onSelected: (value) => Navigator.of(ctx).pop(value),
                onCancel: () => Navigator.of(ctx).pop(),
              ),
            ),
          )
        : await showModalBottomSheet<int>(
            context: context,
            isScrollControlled: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => _QuestionCountContent(
              isRandomNonPro: isRandomNonPro,
              onSelected: (value) => Navigator.of(ctx).pop(value),
              onCancel: () => Navigator.of(ctx).pop(),
            ),
          );

    if (selected == null || !context.mounted) return;

    context.push(
      '/quiz',
      extra: {
        'mode': mode,
        'questionLimit': selected,
      },
    );
  }
}

/// Gedeelde inhoud voor vraagkeuze: centraal dialoog (web) of bottom sheet (mobiel).
class _QuestionCountContent extends StatelessWidget {
  final bool isRandomNonPro;
  final void Function(int) onSelected;
  final VoidCallback onCancel;

  const _QuestionCountContent({
    required this.isRandomNonPro,
    required this.onSelected,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isWideWeb = kIsWeb &&
        MediaQuery.sizeOf(context).width >= kNarrowViewportMaxWidth;
    final maxWidth = isWideWeb ? 520.0 : double.infinity;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hoeveel vragen wil je oefenen?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _QuestionCountButton(
                  limit: 5,
                  onTap: () => onSelected(5),
                ),
                const SizedBox(height: 10),
                _QuestionCountButton(
                  limit: 10,
                  onTap: isRandomNonPro ? null : () => onSelected(10),
                  enabled: !isRandomNonPro,
                  subtitle:
                      isRandomNonPro ? 'Alleen met Roady Pro' : null,
                ),
                const SizedBox(height: 10),
                _QuestionCountButton(
                  limit: 20,
                  onTap: isRandomNonPro ? null : () => onSelected(20),
                  enabled: !isRandomNonPro,
                  subtitle:
                      isRandomNonPro ? 'Alleen met Roady Pro' : null,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Annuleren'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? customIcon;
  final bool enabled;

  const _QuizSelectionCard({
    required this.title,
    required this.description,
    this.icon,
    this.customIcon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
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
          onTap: enabled ? onTap : null,
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
                  child: customIcon ??
                      Icon(
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
    ),
    );
  }
}

class _QuestionCountButton extends StatelessWidget {
  final int limit;
  final VoidCallback? onTap;
  final bool enabled;
  final String? subtitle;

  const _QuestionCountButton({
    required this.limit,
    required this.onTap,
    this.enabled = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceVariant;
    final fgColor = enabled
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant.withOpacity(0.7);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          backgroundColor: bgColor,
          foregroundColor: fgColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$limit vragen'),
            const SizedBox(height: 2),
            Text(
              subtitle ?? '',
              style: TextStyle(
                fontSize: 12,
                color: fgColor.withOpacity(subtitle == null ? 0 : 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrafficSignC43Icon extends StatelessWidget {
  final Color color;

  const _TrafficSignC43Icon({required this.color});

  @override
  Widget build(BuildContext context) {
    const circleSize = 32.0;
    const steelWidth = 6.0;
    const steelHeight = 18.0;
    const overlap = 6.0; // steel loopt onder de cirkel door
    return SizedBox(
      width: 40,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: (40 - steelWidth) / 2,
            top: circleSize - overlap,
            child: Container(
              width: steelWidth,
              height: steelHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Positioned(
            left: (40 - circleSize) / 2,
            top: 0,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: color, width: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

