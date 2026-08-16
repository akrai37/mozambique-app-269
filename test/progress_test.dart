import 'package:flutter_test/flutter_test.dart';

import 'package:mozambique_app/services/progress_service.dart';

void main() {
  group('CategoryProgress defaults', () {
    test('a fresh category has nothing recorded', () {
      const p = CategoryProgress(categoryName: 'colors');
      expect(p.visited, isFalse);
      expect(p.completed, isFalse);
      expect(p.quizScore, 0);
      expect(p.quizTotal, 0);
      expect(p.lastOpened, isNull);
    });

    test('visiting alone does not mark the quiz complete', () {
      const p = CategoryProgress(categoryName: 'colors', visited: true);
      expect(p.visited, isTrue);
      expect(p.completed, isFalse);
    });

    test('a recorded quiz result counts as completed', () {
      const p = CategoryProgress(
        categoryName: 'colors',
        quizScore: 4,
        quizTotal: 6,
      );
      expect(p.completed, isTrue);
    });

    test('scoring zero out of six still counts as completed', () {
      // Completion is about answering every question, not about getting them
      // right — a group that finished and scored nothing has still finished.
      const p = CategoryProgress(
        categoryName: 'colors',
        quizScore: 0,
        quizTotal: 6,
      );
      expect(p.completed, isTrue);
    });
  });

  group('serialisation', () {
    test('round-trips through a map', () {
      final original = CategoryProgress(
        categoryName: 'animals',
        visited: true,
        quizScore: 5,
        quizTotal: 6,
        lastOpened: DateTime.utc(2026, 8, 12, 18, 33),
      );

      final restored = CategoryProgress.fromMap(original.toMap());

      expect(restored.categoryName, original.categoryName);
      expect(restored.visited, original.visited);
      expect(restored.quizScore, original.quizScore);
      expect(restored.quizTotal, original.quizTotal);
      expect(restored.lastOpened, original.lastOpened);
      expect(restored.completed, original.completed);
    });

    test('toMap carries the derived completed flag for Firestore readers', () {
      const p = CategoryProgress(
        categoryName: 'body',
        quizScore: 3,
        quizTotal: 3,
      );
      expect(p.toMap()['completed'], isTrue);
    });

    test('survives a map with missing fields', () {
      // Hive and Firestore can both hand back partial documents — an older
      // schema, or a hand-edited record in the console.
      final p = CategoryProgress.fromMap({'categoryName': 'face'});
      expect(p.categoryName, 'face');
      expect(p.visited, isFalse);
      expect(p.quizScore, 0);
      expect(p.lastOpened, isNull);
    });

    test('survives a malformed timestamp', () {
      final p = CategoryProgress.fromMap({
        'categoryName': 'face',
        'lastOpened': 'not a date',
      });
      expect(p.lastOpened, isNull);
    });

    test('accepts numeric scores stored as doubles', () {
      // Firestore hands numbers back as num, and a value written as 5 can come
      // back as 5.0 — casting straight to int would throw.
      final p = CategoryProgress.fromMap({
        'categoryName': 'colors',
        'quizScore': 5.0,
        'quizTotal': 6.0,
      });
      expect(p.quizScore, 5);
      expect(p.quizTotal, 6);
    });
  });

  group('copyWith', () {
    test('changes only what it is given', () {
      const original = CategoryProgress(
        categoryName: 'colors',
        visited: true,
        quizScore: 2,
        quizTotal: 6,
      );

      final updated = original.copyWith(quizScore: 5);

      expect(updated.categoryName, 'colors');
      expect(updated.visited, isTrue);
      expect(updated.quizTotal, 6);
      expect(updated.quizScore, 5);
    });

    test('keeps the category name immutable', () {
      const original = CategoryProgress(categoryName: 'colors');
      expect(original.copyWith(visited: true).categoryName, 'colors');
    });
  });
}
