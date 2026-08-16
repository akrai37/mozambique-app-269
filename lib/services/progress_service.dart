import 'dart:developer';

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

  Box get _box => Hive.box(boxName);

  /// Firestore is only reachable if Firebase was initialized at startup, which
  /// does not happen in local-content mode. Checking the app list avoids
  /// throwing rather than relying on a build flag.
  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  CategoryProgress forCategory(String categoryName) {
    final Object? raw = _box.get(categoryName);
    if (raw is Map) return CategoryProgress.fromMap(raw);
    return CategoryProgress(categoryName: categoryName);
  }

  /// Every category with recorded progress.
  Map<String, CategoryProgress> all() {
    final Map<String, CategoryProgress> result = {};
    for (final Object? key in _box.keys) {
      if (key is! String) continue;
      final Object? raw = _box.get(key);
      if (raw is Map) result[key] = CategoryProgress.fromMap(raw);
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
    await _box.put(progress.categoryName, progress.toMap());
    log('Progress saved locally: ${progress.categoryName} '
        '${progress.quizScore}/${progress.quizTotal}');

    await _pushToFirestore(progress);
  }

  /// Best-effort upload. A failure here is not an error the learner should ever
  /// see — the data is already safely on the device.
  Future<void> _pushToFirestore(CategoryProgress progress) async {
    if (!_firebaseAvailable) return;

    try {
      await FirebaseFirestore.instance
          .collection(progressCollection)
          .doc(progress.categoryName)
          .set(progress.toMap(), SetOptions(merge: true));

      log('Progress synced to $progressCollection/${progress.categoryName}');
    } catch (err) {
      log('Progress upload failed (kept locally): $err');
    }
  }
}
