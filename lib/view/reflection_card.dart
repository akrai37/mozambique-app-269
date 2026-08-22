import 'package:flutter/material.dart';

import 'package:mozambique_app/services/progress_service.dart';
import 'package:mozambique_app/view_model/progress_summary.dart';

/// Shown when a quiz is finished: how this attempt went, and how the group is
/// doing overall.
///
/// Two levels on purpose. The stars are the reward for the quiz just finished,
/// which is the moment a learner cares about. The row underneath is cumulative
/// — one mark per category the group has completed — so a session builds toward
/// something visible instead of each quiz standing alone.
///
/// Almost entirely non-textual, like the rest of the content: stars, a face,
/// and a row of marks. The two numbers are there for the moderator.
class ReflectionCard extends StatelessWidget {
  /// Correct answers in the quiz just finished.
  final int score;

  /// Questions in the quiz just finished.
  final int total;

  const ReflectionCard({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final int stars = starsFor(score: score, total: total);
    final SessionSummary summary = SessionSummary.from(ProgressService().all());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFECF0F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D3E50), width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // This quiz — stars are the headline.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 3; i++)
                Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 72,
                  color: i < stars
                      ? const Color(0xFFF1C40F)
                      : const Color(0xFF95A5A5),
                ),
              const SizedBox(width: 24),
              Image(
                image: AssetImage(
                  score == total
                      ? 'assets/images/bigSmile.png'
                      : 'assets/images/smile.png',
                ),
                height: 84,
                width: 84,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '$score / $total',
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3E50),
            ),
          ),

          // Only worth showing once more than this one quiz has been done —
          // before that it just repeats the line above.
          if (summary.categoriesCompleted > 1) ...[
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF95A5A5), thickness: 1),
            const SizedBox(height: 16),

            // One mark per completed category: the session so far, at a glance.
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                summary.categoriesCompleted,
                (_) => Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(Icons.check, size: 26, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '${summary.categoriesCompleted} categorias  ·  '
              '${summary.totalCorrect} / ${summary.totalQuestions}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
