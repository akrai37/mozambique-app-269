import 'package:flutter_test/flutter_test.dart';

import 'package:mozambique_app/services/progress_service.dart';
import 'package:mozambique_app/view_model/quiz_feedback.dart';

/// Written before quiz_feedback.dart existed.

CategoryProgress done(String name, int score, int total) => CategoryProgress(
      categoryName: name,
      visited: true,
      quizScore: score,
      quizTotal: total,
    );

void main() {
  group('tone', () {
    test('a perfect score is excellent', () {
      final f = feedbackFor(category: 'colors', score: 6, total: 6, allProgress: {});
      expect(f.tone, FeedbackTone.excellent);
    });

    test('a solid score is good', () {
      final f = feedbackFor(category: 'colors', score: 4, total: 6, allProgress: {});
      expect(f.tone, FeedbackTone.good);
    });

    test('a weak score asks them to keep practising', () {
      final f = feedbackFor(category: 'colors', score: 1, total: 6, allProgress: {});
      expect(f.tone, FeedbackTone.keepPractising);
    });

    test('zero questions does not crash or claim excellence', () {
      final f = feedbackFor(category: 'colors', score: 0, total: 0, allProgress: {});
      expect(f.tone, FeedbackTone.keepPractising);
    });
  });

  group('improvement', () {
    test('beating the previous best is called out', () {
      final f = feedbackFor(
        category: 'colors', score: 5, total: 6,
        previousBest: 3, allProgress: {},
      );
      expect(f.improved, isTrue);
    });

    test('matching the previous best is not an improvement', () {
      final f = feedbackFor(
        category: 'colors', score: 3, total: 6,
        previousBest: 3, allProgress: {},
      );
      expect(f.improved, isFalse);
    });

    test('a first attempt is not framed as an improvement', () {
      // Nothing to beat yet. Saying "better than before" on a first try is a
      // small lie, and the moderator will notice it.
      final f = feedbackFor(
        category: 'colors', score: 5, total: 6,
        previousBest: null, allProgress: {},
      );
      expect(f.improved, isFalse);
    });
  });

  group('what to practise next', () {
    test('suggests the weakest completed category', () {
      final f = feedbackFor(
        category: 'colors', score: 6, total: 6,
        allProgress: {
          'colors': done('colors', 6, 6),
          'animals': done('animals', 1, 6),
          'fruits': done('fruits', 4, 6),
        },
      );
      expect(f.suggestedCategory, 'animals');
    });

    test('suggests nothing when everything is going well', () {
      final f = feedbackFor(
        category: 'colors', score: 6, total: 6,
        allProgress: {
          'colors': done('colors', 6, 6),
          'fruits': done('fruits', 5, 6),
        },
      );
      expect(f.suggestedCategory, isNull);
    });

    test('suggests repeating this category when it is the weak one', () {
      final f = feedbackFor(
        category: 'animals', score: 1, total: 6,
        allProgress: {
          'colors': done('colors', 6, 6),
          'animals': done('animals', 1, 6),
        },
      );
      expect(f.suggestedCategory, 'animals');
    });

    test('ignores categories with no quiz result', () {
      final f = feedbackFor(
        category: 'colors', score: 6, total: 6,
        allProgress: {
          'colors': done('colors', 6, 6),
          'body': const CategoryProgress(categoryName: 'body', visited: true),
        },
      );
      expect(f.suggestedCategory, isNull);
    });
  });

  group('message', () {
    test('is never empty', () {
      for (final score in [0, 1, 3, 6]) {
        final f = feedbackFor(
            category: 'colors', score: score, total: 6, allProgress: {});
        expect(f.message.trim(), isNotEmpty, reason: 'score $score');
      }
    });

    test('is in Portuguese, matching the rest of the interface', () {
      final f = feedbackFor(category: 'colors', score: 6, total: 6, allProgress: {});
      expect(f.message, matches(RegExp(r'[A-Za-zÀ-ÿ]')));
      expect(f.message.toLowerCase(), isNot(contains('score')));
    });
  });
}
