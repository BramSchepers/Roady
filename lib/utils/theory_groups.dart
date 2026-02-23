import 'package:flutter/material.dart';

/// Eén groep theorie-hoofdstukken (bijv. "intro", "openbareweg").
class TheoryGroup {
  final String id;
  final String title;
  final IconData icon;
  final List<String> chapterIds;

  const TheoryGroup({
    required this.id,
    required this.title,
    required this.icon,
    required this.chapterIds,
  });
}

/// Hardcoded 6 groepen voor de theorie-overzicht (web + mobiel).
final List<TheoryGroup> theoryGroups = [
  const TheoryGroup(
    id: 'intro',
    title: 'Intro',
    icon: Icons.menu_book_rounded,
    chapterIds: ['chapter_00'],
  ),
  const TheoryGroup(
    id: 'openbareweg',
    title: 'Openbareweg',
    icon: Icons.route_rounded,
    chapterIds: [
      'chapter_01',
      'chapter_02',
      'chapter_03',
      'chapter_04',
      'chapter_05',
      'chapter_06',
    ],
  ),
  const TheoryGroup(
    id: 'voetgangers_bestuurders',
    title: 'Voetgangers & Bestuurders',
    icon: Icons.directions_walk_rounded,
    chapterIds: ['chapter_07', 'chapter_08'],
  ),
  const TheoryGroup(
    id: 'de_auto',
    title: 'Eigenschappen Auto',
    icon: Icons.build_circle_rounded,
    chapterIds: ['chapter_09', 'chapter_10', 'chapter_11'],
  ),
  const TheoryGroup(
    id: 'de_snelheid',
    title: 'De Snelheid',
    icon: Icons.speed_rounded,
    chapterIds: ['chapter_12', 'chapter_13'],
  ),
  const TheoryGroup(
    id: 'kruisen_inhalen',
    title: 'Kruisen en Inhalen',
    icon: Icons.merge_type_rounded,
    chapterIds: ['chapter_14', 'chapter_15'],
  ),
];
