import 'package:mozambique_app/services/progress_service.dart';

/// A short read on how a finished quiz went, and what to do next.
///
/// Everything here comes from data the app already records — this attempt, the
/// group's previous best, and their scores in other categories. Nothing is
/// invented or guessed, because a moderator will notice encouragement that does
/// not match what actually happened.
///
/// Written test-first, from test/quiz_feedback_test.dart.

enum FeedbackTone { excellent, good, keepPractising }

class QuizFeedback {
  final FeedbackTone tone;

  /// Shown to the moderator. In Portuguese, matching the rest of the interface.
  final String message;

  /// True only when this attempt beat a previous recorded score.
  final bool improved;

  /// The category most worth practising next, or null if nothing stands out.
  final String? suggestedCategory;

  const QuizFeedback({
    required this.tone,
    required this.message,
    this.improved = false,
    this.suggestedCategory,
  });
}

/// Anything below this is treated as needing more practice.
const double _weakThreshold = 0.6;

QuizFeedback feedbackFor({
  required String category,
  required int score,
  required int total,
  required Map<String, CategoryProgress> allProgress,
  int? previousBest,
}) {
  final double ratio = total > 0 ? score / total : 0;

  final FeedbackTone tone = ratio >= 0.9
      ? FeedbackTone.excellent
      : ratio >= _weakThreshold
          ? FeedbackTone.good
          : FeedbackTone.keepPractising;

  // Only an improvement if there was something to beat. Framing a first attempt
  // as "better than before" is a small lie the moderator would spot.
  final bool improved = previousBest != null && score > previousBest;

  final String? weakest = _weakestCategory(allProgress);

  final String message = switch (tone) {
    FeedbackTone.excellent => 'Excelente! $score de $total.',
    FeedbackTone.good => 'Muito bem! $score de $total.',
    FeedbackTone.keepPractising => 'Continue a praticar. $score de $total.',
  };

  return QuizFeedback(
    tone: tone,
    message: improved ? '$message Melhor do que antes!' : message,
    improved: improved,
    suggestedCategory: weakest,
  );
}

/// The completed category with the lowest score, if any is below the threshold.
///
/// Categories that were opened but never quizzed are skipped: there is no
/// result to judge, and suggesting one would be guessing.
String? _weakestCategory(Map<String, CategoryProgress> allProgress) {
  String? weakest;
  double lowest = _weakThreshold;

  for (final MapEntry<String, CategoryProgress> entry in allProgress.entries) {
    final CategoryProgress progress = entry.value;
    if (!progress.completed || progress.quizTotal <= 0) continue;

    final double ratio = progress.quizScore / progress.quizTotal;
    if (ratio < lowest) {
      lowest = ratio;
      weakest = entry.key;
    }
  }

  return weakest;
}
