import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theory_models.dart';

/// Firestore: collection [theoryChapters]. Each document = one chapter.
/// Fields: id (string), title (map: nl, fr, en -> string), imageUrl (string),
/// lessons (array of maps). Each lesson map: id, lottieAsset, content (map:
/// nl/fr/en -> { title, description }), imageUrl (optional string).
const String _collectionId = 'theoryChapters';

/// Fetches theory chapters and lessons from Firestore.
class TheoryRepository {
  TheoryRepository._();
  static final TheoryRepository instance = TheoryRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TheoryChapter>? _cache;

  /// Returns chapters from Firestore (ordered by id), or empty list on error/empty. Caches result.
  Future<List<TheoryChapter>> getChapters() async {
    try {
      final snapshot = await _firestore.collection(_collectionId).get();
      if (snapshot.docs.isEmpty) {
        _cache = [];
        return [];
      }

      final list = <TheoryChapter>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] ??= doc.id;
        list.add(TheoryChapter.fromMap(data));
      }
      list.sort((a, b) => a.id.compareTo(b.id));
      _cache = list;
      return list;
    } catch (e) {
      // Return cached data if available, otherwise empty list
      return _cache ?? [];
    }
  }

  /// Returns cached chapters, or empty list if not yet loaded. Use for progress calc without await.
  List<TheoryChapter> getChaptersCachedSync() => _cache ?? [];
}
