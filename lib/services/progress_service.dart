import 'dart:developer';
// show Random: dart:math also exports log(), which collides with
// dart:developer's log() used throughout this file.
import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';

/// Firestore collection that progress is written to.
///
/// Deliberately namespaced and separate from the app's own `app_content` and
/// `dev_content` collections. Firestore collections are independent, so writing
/// here cannot affect the content the live app reads. Override with:
///   --dart-define=PROGRESS_COLLECTION=progress_someone_else
const String progressCollection = String.fromEnvironment(
  'PROGRESS_COLLECTION',
  defaultValue: 'progress_ankush',
);

/// What a group has done in one category.
///
/// Plain data rather than a Hive-annotated class: progress is a handful of
/// scalars, so it is stored as a Map and needs no generated adapter or new
/// typeId. Keeping it codegen-free means `build_runner` is not required.
class CategoryProgress {
  final String categoryName;
  final bool visited;
  final int quizScore;
  final int quizTotal;
  final DateTime? lastOpened;

  const CategoryProgress({
    required this.categoryName,
    this.visited = false,
    this.quizScore = 0,
    this.quizTotal = 0,
    this.lastOpened,
  });

  /// True once a quiz result has been recorded for this category.
  ///
  /// A result is only ever written when every question has been answered, so
  /// having one is the same thing as having completed the quiz.
  bool get completed => quizTotal > 0;

  Map<String, dynamic> toMap() => {
        'categoryName': categoryName,
        'visited': visited,
        'completed': completed,
        'quizScore': quizScore,
        'quizTotal': quizTotal,
        'lastOpened': lastOpened?.toIso8601String(),
      };

  factory CategoryProgress.fromMap(Map<dynamic, dynamic> map) {
    final Object? opened = map['lastOpened'];
    return CategoryProgress(
      categoryName: map['categoryName'] as String? ?? '',
      visited: map['visited'] as bool? ?? false,
      quizScore: (map['quizScore'] as num?)?.toInt() ?? 0,
      quizTotal: (map['quizTotal'] as num?)?.toInt() ?? 0,
      lastOpened: opened is String ? DateTime.tryParse(opened) : null,
    );
  }

  CategoryProgress copyWith({
    bool? visited,
    int? quizScore,
    int? quizTotal,
    DateTime? lastOpened,
  }) =>
      CategoryProgress(
        categoryName: categoryName,
        visited: visited ?? this.visited,
        quizScore: quizScore ?? this.quizScore,
        quizTotal: quizTotal ?? this.quizTotal,
        lastOpened: lastOpened ?? this.lastOpened,
      );
}

/// Records what a group has done, locally first and in Firestore when possible.
///
/// The write order is deliberate and mirrors how the app already handles
/// content: Hive is the source of truth on the device, and the network is a
/// bonus. A tablet with no connection still records everything; Firestore just
/// makes it visible to whoever is running the programme.
class ProgressService {
  static const String boxName = 'progress';

  // Reserved keys for group metadata, prefixed so they cannot collide with a
  // category name.
  static const String _groupIdKey = '__groupId';
  static const String _groupNameKey = '__groupName';
  static const String _migratedKey = '__migratedToGroups';

  Box get _box => Hive.box(boxName);

  /// Firestore is only reachable if Firebase was initialized at startup, which
  /// does not happen in local-content mode. Checking the app list avoids
  /// throwing rather than relying on a build flag.
  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  // ---------------- group identity ----------------

  /// Identifies the group using this tablet.
  ///
  /// Generated on first use and stored on the device. There is no login: the
  /// learners cannot read one, and the tablet is shared rather than personal.
  /// The group is the unit that makes sense here, not the individual.
  ///
  /// Without this, every tablet wrote to the same Firestore document, so a
  /// second tablet would silently overwrite the first one's progress.
  String get groupId {
    final Object? existing = _box.get(_groupIdKey);
    if (existing is String && existing.isNotEmpty) return existing;

    final String created = _generateGroupId();
    _box.put(_groupIdKey, created);
    _adoptUngroupedProgress(created);
    return created;
  }

  /// Human-readable label a moderator can set, e.g. "Namaacha Tuesday".
  ///
  /// Optional, and typed by the moderator rather than a learner — moderators
  /// can read, which is why a text field is acceptable here and nowhere else.
  String? get groupName {
    final Object? name = _box.get(_groupNameKey);
    return (name is String && name.trim().isNotEmpty) ? name.trim() : null;
  }

  Future<void> setGroupName(String name) async {
    await _box.put(_groupNameKey, name.trim());
    await _pushGroupDoc();
  }

  /// Starts a fresh group on this tablet.
  ///
  /// Badges clear because progress is stored per group, but nothing is
  /// deleted — the previous group's record stays on the device and in
  /// Firestore under its own id.
  Future<void> startNewGroup({String? name}) async {
    await _box.put(_groupIdKey, _generateGroupId());
    await _box.put(_groupNameKey, name?.trim() ?? '');
    await _pushGroupDoc();
  }

  String _generateGroupId() {
    final int stamp = DateTime.now().microsecondsSinceEpoch;
    final int salt = Random().nextInt(1 << 20);
    return 'g${stamp.toRadixString(36)}${salt.toRadixString(36)}';
  }

  /// Progress written before groups existed was keyed by bare category name.
  /// Re-key it under the first group so a tablet that already has history does
  /// not appear to lose it.
  void _adoptUngroupedProgress(String newGroupId) {
    if (_box.get(_migratedKey) == true) return;

    for (final Object? key in _box.keys.toList()) {
      if (key is! String || key.startsWith('__') || key.contains('::')) continue;

      final Object? raw = _box.get(key);
      if (raw is Map) {
        _box.put('$newGroupId::$key', raw);
        _box.delete(key);
      }
    }

    _box.put(_migratedKey, true);
  }

  /// Hive key for a category under the current group.
  ///
  /// Public so widgets can listen to exactly the key they care about rather
  /// than rebuilding on every unrelated write.
  String hiveKeyFor(String categoryName) => '$groupId::$categoryName';

  // ---------------- reading ----------------

  CategoryProgress forCategory(String categoryName) {
    final Object? raw = _box.get(hiveKeyFor(categoryName));
    if (raw is Map) return CategoryProgress.fromMap(raw);
    return CategoryProgress(categoryName: categoryName);
  }

  /// Every category with recorded progress, for the current group only.
  Map<String, CategoryProgress> all() {
    final String prefix = '$groupId::';
    final Map<String, CategoryProgress> result = {};

    for (final Object? key in _box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;

      final Object? raw = _box.get(key);
      if (raw is Map) {
        result[key.substring(prefix.length)] = CategoryProgress.fromMap(raw);
      }
    }

    return result;
  }

  /// Note that a category was opened.
  Future<void> markVisited(String categoryName) async {
    final CategoryProgress current = forCategory(categoryName);
    await _save(current.copyWith(visited: true, lastOpened: DateTime.now()));
  }

  /// Record a finished quiz. Keeps the better of the old and new score, so
  /// re-running a quiz to practise cannot make a group's record look worse.
  Future<void> recordQuizResult(
    String categoryName, {
    required int score,
    required int total,
  }) async {
    final CategoryProgress current = forCategory(categoryName);
    final bool isImprovement = !current.completed || score > current.quizScore;

    await _save(current.copyWith(
      visited: true,
      quizScore: isImprovement ? score : current.quizScore,
      quizTotal: total,
      lastOpened: DateTime.now(),
    ));
  }

  Future<void> _save(CategoryProgress progress) async {
    // Local first: this must not depend on the network.
    await _box.put(hiveKeyFor(progress.categoryName), progress.toMap());
    log('Progress saved locally: ${progress.categoryName} '
        '${progress.quizScore}/${progress.quizTotal}');

    await _pushGroupDoc();
    await _pushToFirestore(progress);
  }

  /// Best-effort upload. A failure here is not an error the learner should ever
  /// see — the data is already safely on the device.
  Future<void> _pushToFirestore(CategoryProgress progress) async {
    if (!_firebaseAvailable) return;

    try {
      // Nested under the group, mirroring how the app's own content is laid
      // out (collection -> doc -> subcollection). Without the group in the
      // path, every tablet would write to the same document.
      await FirebaseFirestore.instance
          .collection(progressCollection)
          .doc(groupId)
          .collection('categories')
          .doc(progress.categoryName)
          .set(progress.toMap(), SetOptions(merge: true));

      log('Progress synced to $progressCollection/$groupId/'
          'categories/${progress.categoryName}');
    } catch (err) {
      log('Progress upload failed (kept locally): $err');
    }
  }

  /// Writes the group's own document, so the collection lists readable groups
  /// rather than bare ids with nothing but subcollections under them.
  Future<void> _pushGroupDoc() async {
    if (!_firebaseAvailable) return;

    try {
      await FirebaseFirestore.instance
          .collection(progressCollection)
          .doc(groupId)
          .set({
        'groupId': groupId,
        'groupName': groupName,
        'lastActive': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (err) {
      log('Group document upload failed (kept locally): $err');
    }
  }
}
