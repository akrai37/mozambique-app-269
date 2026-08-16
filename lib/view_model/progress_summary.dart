import 'package:mozambique_app/services/progress_service.dart';

/// Turns stored progress into the handful of values the UI needs.
///
/// Kept out of the widgets deliberately. The search filter in this app carried
/// a bug for a year because it lived inside widget state where no test could
/// reach it — see view_model/home_search.dart. This file was written
/// test-first, from test/progress_summary_test.dart.

/// What to draw on a home card.
enum CategoryBadge {
  /// Never opened — draw nothing, so the grid stays uncluttered.
  none,

  /// Opened, but the quiz was not finished.
  visited,

  /// The quiz was completed, whatever the score.
  completed,
}

CategoryBadge badgeFor(CategoryProgress progress) {
  // Completion is checked first: finishing is the thing being marked, not
  // being right. A group that scored zero still finished.
  if (progress.completed) return CategoryBadge.completed;
  if (progress.visited) return CategoryBadge.visited;
  return CategoryBadge.none;
}

/// Stars out of three for a finished quiz.
///
/// Weighted generously on purpose. These learners are non-literate adults
/// meeting both a new language and their first tablet; the stars are there to
/// encourage a group to keep going, not to grade them. Anyone who gets a single
/// answer right earns something.
int starsFor({required int score, required int total}) {
  if (total <= 0 || score <= 0) return 0;

  final double fraction = score / total;

  if (fraction >= 0.9) return 3;
  if (fraction >= 0.6) return 2;
  return 1;
}

/// Everything a reflection card needs about one session.
class SessionSummary {
  final int categoriesVisited;
  final int categoriesCompleted;
  final int totalCorrect;
  final int totalQuestions;

  const SessionSummary({
    required this.categoriesVisited,
    required this.categoriesCompleted,
    required this.totalCorrect,
    required this.totalQuestions,
  });

  /// False when there is nothing worth showing, so the card can be hidden
  /// rather than displayed empty.
  bool get hasAnything => categoriesVisited > 0;

  /// Stars for the session as a whole, on the same scale as a single quiz.
  int get stars => starsFor(score: totalCorrect, total: totalQuestions);

  factory SessionSummary.from(Map<String, CategoryProgress> progressByCategory) {
    int visited = 0;
    int completed = 0;
    int correct = 0;
    int questions = 0;

    for (final CategoryProgress progress in progressByCategory.values) {
      if (progress.visited) visited++;

      if (progress.completed) {
        completed++;
        correct += progress.quizScore;
        questions += progress.quizTotal;
      }
    }

    return SessionSummary(
      categoriesVisited: visited,
      categoriesCompleted: completed,
      totalCorrect: correct,
      totalQuestions: questions,
    );
  }
}
