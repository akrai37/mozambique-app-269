import 'package:flutter/material.dart';

/// A running score for a quiz, shown as one dot per question.
///
/// Deliberately non-textual: the learners this app is built for cannot read, so
/// the state has to be legible as shape and colour alone. A filled green dot
/// with a tick means correct, red with a cross means wrong, and an empty
/// outline means not yet answered. The numeric score is there for the
/// moderator, not the learner.
class QuizScore extends StatelessWidget {
  /// Question index -> whether the first answer was correct.
  final Map<int, bool> answers;

  /// Total number of questions in this quiz.
  final int total;

  /// Clears the answers so the quiz can be taken again.
  final VoidCallback? onTryAgain;

  const QuizScore({
    super.key,
    required this.answers,
    required this.total,
    this.onTryAgain,
  });


  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFECF0F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // One dot per question, in order.
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(total, (index) {
              final bool? correct = answers[index];
              return _ScoreDot(correct: correct);
            }),
          ),

          // The score and the face used to live here as well, and once the
          // reflection card was added they appeared twice, stacked. This bar is
          // now only a progress indicator — how far through you are — and the
          // card owns the result.

          // Only offered once something has been answered — an empty quiz has
          // nothing to clear, and an extra control would just be clutter.
          if (answers.isNotEmpty && onTryAgain != null) ...[
            const SizedBox(width: 32),
            ElevatedButton(
              onPressed: onTryAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFF2D3E50),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                side: const BorderSide(color: Color(0xFF2D3E50), width: 2.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Same label and glyph as the reset button on practice
              // conversations, so the two read as the same action.
              child: const Text(
                'Reiniciar ⟲',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreDot extends StatelessWidget {
  /// null = not yet answered.
  final bool? correct;

  const _ScoreDot({required this.correct});

  @override
  Widget build(BuildContext context) {
    final bool answered = correct != null;
    final Color color = !answered
        ? const Color(0xFF95A5A5)
        : (correct! ? Colors.green : Colors.red);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: answered ? color : Colors.transparent,
        border: Border.all(color: color, width: 3),
      ),
      child: answered
          ? Icon(
              correct! ? Icons.check : Icons.close,
              size: 28,
              color: Colors.white,
            )
          : null,
    );
  }
}
