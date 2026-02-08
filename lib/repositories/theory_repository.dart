import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theory_models.dart';
import '../debug_log_stub.dart' if (dart.library.io) '../debug_log_io.dart' as _log;

/// Firestore: collection [theoryChapters]. Each document = one chapter.
/// Fields: id (string), title (map: nl, fr, en -> string), imageUrl (string),
/// lessons (array of maps). Each lesson map: id, lottieAsset, content (map:
/// nl/fr/en -> { title, description }), imageUrl (optional string).
const String _collectionId = 'theoryChapters';

/// Fetches theory chapters and lessons from Firestore.
/// Falls back to [dummyChapters] when Firestore is empty, fails, or is offline.
class TheoryRepository {
  TheoryRepository._();
  static final TheoryRepository instance = TheoryRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TheoryChapter>? _cache;

  /// Returns chapters from Firestore (ordered by id), or [dummyChapters] on error/empty. Caches result.
  Future<List<TheoryChapter>> getChapters() async {
    // #region agent log
    _log.debugLog('theory_repository.dart', 'getChapters started', {}, 'A');
    // #endregion
    try {
      final snapshot = await _firestore.collection(_collectionId).get();
      // #region agent log
      _log.debugLog('theory_repository.dart', 'snapshot received', {
        'docCount': snapshot.docs.length,
        'empty': snapshot.docs.isEmpty,
        'firstDocId': snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null,
      }, 'B');
      // #endregion
      if (snapshot.docs.isEmpty) {
        _cache = dummyChapters;
        // #region agent log
        _log.debugLog('theory_repository.dart', 'returning dummyChapters (empty)', {'length': dummyChapters.length}, 'D');
        // #endregion
        return dummyChapters;
      }

      final list = <TheoryChapter>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] ??= doc.id;
        list.add(TheoryChapter.fromMap(data));
      }
      list.sort((a, b) => a.id.compareTo(b.id));
      _cache = list;
      // #region agent log
      _log.debugLog('theory_repository.dart', 'returning Firestore list', {
        'length': list.length,
        'firstChapterId': list.isNotEmpty ? list.first.id : null,
      }, 'D');
      // #endregion
      return list;
    } catch (e, st) {
      // #region agent log
      _log.debugLog('theory_repository.dart', 'getChapters exception', {
        'error': e.toString(),
        'stack': st.toString().split('\n').take(3).join(' '),
      }, 'C');
      // #endregion
      _cache = dummyChapters;
      return dummyChapters;
    }
  }

  /// Returns cached chapters, or [dummyChapters] if not yet loaded. Use for progress calc without await.
  List<TheoryChapter> getChaptersCachedSync() => _cache ?? dummyChapters;
}
