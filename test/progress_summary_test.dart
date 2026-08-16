import 'package:flutter_test/flutter_test.dart';

import 'package:mozambique_app/services/progress_service.dart';
import 'package:mozambique_app/view_model/progress_summary.dart';

/// Written before progress_summary.dart existed. These tests define what the
/// home-card badges and the end-of-category reflection card should show; the
/// implementation was written to satisfy them.

CategoryProgress fresh(String name) => CategoryProgress(categoryName: name);

CategoryProgress visited(String name) =>
    CategoryProgress(categoryName: name, visited: true);

CategoryProgress done(String name, int score, int total) => CategoryProgress(
      categoryName: name,
      visited: true,
      quizScore: score,
      quizTotal: total,
    );

void main() {
  group('badgeFor', () {
    test('a category nobody has opened shows nothing', () {
      expect(badgeFor(fresh('colors')), CategoryBadge.none);
    });

    test('an opened category shows the visited badge', () {
      expect(badgeFor(visited('colors')), CategoryBadge.visited);
    });

    test('a finished quiz shows the completed badge', () {
      expect(badgeFor(done('colors', 4, 6)), CategoryBadge.completed);
    });

    test('completed wins even when every answer was wrong', () {
      // Finishing is the achievement being marked, not being right. A group
      // that got nothing right still finished, and hiding that would make the
      // home screen look like they had not tried.
      expect(badgeFor(done('colors', 0, 6)), CategoryBadge.completed);
    });
  });

  group('starsFor', () {
    test('no questions means no stars, and does not divide by zero', () {
      expect(starsFor(score: 0, total: 0), 0);
    });

    test('nothing correct earns no stars', () {
      expect(starsFor(score: 0, total: 6), 0);
    });

    test('a low score still earns one star for finishing', () {
      expect(starsFor(score: 2, total: 6), 1); // 33%
    });

    test('a solid score earns two', () {
      expect(starsFor(score: 4, total: 6), 2); // 67%
    });

    test('a near-perfect score earns three', () {
      expect(starsFor(score: 5, total: 5), 3); // 100%
      expect(starsFor(score: 9, total: 10), 3); // 90%
    });

    test('the boundaries land on the generous side', () {
      expect(starsFor(score: 6, total: 10), 2); // exactly 60% -> two
      expect(starsFor(score: 5, total: 10), 1); // just under -> one
    });

    test('never returns more than three or fewer than zero', () {
      for (int total = 1; total <= 12; total++) {
        for (int score = 0; score <= total; score++) {
          final stars = starsFor(score: score, total: total);
          expect(stars, inInclusiveRange(0, 3),
              reason: '$score/$total gave $stars');
        }
      }
    });
  });

  group('SessionSummary', () {
    test('an empty record summarises to zeroes', () {
      final s = SessionSummary.from({});
      expect(s.categoriesVisited, 0);
      expect(s.categoriesCompleted, 0);
      expect(s.totalCorrect, 0);
      expect(s.totalQuestions, 0);
      expect(s.hasAnything, isFalse);
    });

    test('counts visited and completed separately', () {
      final s = SessionSummary.from({
        'colors': done('colors', 5, 8),
        'face': visited('face'),
        'body': fresh('body'),
      });

      expect(s.categoriesVisited, 2); // colors and face; body was never opened
      expect(s.categoriesCompleted, 1); // only colors has a quiz result
      expect(s.hasAnything, isTrue);
    });

    test('totals quiz answers across categories', () {
      final s = SessionSummary.from({
        'colors': done('colors', 5, 8),
        'face': done('face', 3, 4),
      });

      expect(s.totalCorrect, 8);
      expect(s.totalQuestions, 12);
    });

    test('a visited-but-unfinished category adds no questions', () {
      final s = SessionSummary.from({
        'colors': done('colors', 5, 8),
        'face': visited('face'),
      });

      expect(s.totalQuestions, 8);
      expect(s.totalCorrect, 5);
    });
  });
}
