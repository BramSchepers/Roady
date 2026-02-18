import 'package:flutter/foundation.dart' show kIsWeb;

// --- Data Models ---

class TheoryLesson {
  final String id;
  final String lottieAsset;
  final Map<String, dynamic> content;
  final String? imageUrl;
  final String? imageUrlWeb;

  TheoryLesson({
    required this.id,
    required this.lottieAsset,
    required this.content,
    this.imageUrl,
    this.imageUrlWeb,
  });

  /// URL voor weergave: web gebruikt imageUrlWeb (full), mobiel imageUrl (small).
  String? get effectiveImageUrl =>
      (kIsWeb && imageUrlWeb != null && imageUrlWeb!.isNotEmpty)
          ? imageUrlWeb
          : imageUrl;

  String getTitle(String lang) =>
      content[lang]?['title'] ?? content['nl']['title'];
  String getDescription(String lang) =>
      content[lang]?['description'] ?? content['nl']['description'];

  /// From Firestore (or any Map). [map] may be from a document field.
  static TheoryLesson fromMap(Map<String, dynamic> map) {
    final contentRaw = map['content'];
    Map<String, dynamic> content = {};
    if (contentRaw is Map) {
      for (final e in contentRaw.entries) {
        if (e.value is Map) {
          content[e.key.toString()] =
              Map<String, dynamic>.from(e.value as Map);
        }
      }
    }
    return TheoryLesson(
      id: map['id'] as String? ?? '',
      lottieAsset:
          map['lottieAsset'] as String? ?? 'assets/lottie/car.lottie',
      content: content.isNotEmpty
          ? content
          : {'nl': {'title': '', 'description': ''}},
      imageUrl: map['imageUrl'] as String?,
      imageUrlWeb: map['imageUrlWeb'] as String?,
    );
  }
}

class TheoryChapter {
  final String id;
  final Map<String, String> title;
  final String imageUrl; // Asset path for the chapter cover
  final List<TheoryLesson> lessons;

  TheoryChapter({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.lessons,
  });

  String getTitle(String lang) => title[lang] ?? title['nl']!;

  /// From Firestore document (or any Map).
  static TheoryChapter fromMap(Map<String, dynamic> map) {
    final titleRaw = map['title'];
    Map<String, String> titleMap = {};
    if (titleRaw is Map) {
      for (final e in titleRaw.entries) {
        titleMap[e.key.toString()] = e.value?.toString() ?? '';
      }
    }
    if (titleMap.isEmpty) titleMap['nl'] = '';

    final lessonsRaw = map['lessons'];
    List<TheoryLesson> lessonsList = [];
    if (lessonsRaw is List) {
      for (final item in lessonsRaw) {
        if (item is Map) {
          lessonsList
              .add(TheoryLesson.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return TheoryChapter(
      id: map['id'] as String? ?? '',
      title: titleMap,
      imageUrl: map['imageUrl'] as String? ?? 'assets/illustrations/Background_hero.svg',
      lessons: lessonsList,
    );
  }
}


// --- Dummy Data Removed ---

