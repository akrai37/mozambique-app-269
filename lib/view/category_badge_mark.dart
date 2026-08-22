import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mozambique_app/services/progress_service.dart';
import 'package:mozambique_app/view_model/progress_summary.dart';

/// The progress marker in the corner of a home card.
///
/// Three states, distinguished by shape and colour rather than words, since
/// the learners cannot read:
///   - never opened  -> nothing at all, so the grid stays uncluttered
///   - opened        -> a hollow grey ring
///   - quiz finished -> a filled green tick, with stars underneath
///
/// Which state applies is decided by badgeFor() in view_model/progress_summary.dart,
/// which is unit tested. This widget only draws.
class CategoryBadgeMark extends StatelessWidget {
  final String categoryName;

  const CategoryBadgeMark({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Listening to the box rather than reading once: a learner finishes a quiz
    // and navigates back, and the card behind them has to already be updated.
    // Reading at build time would leave stale badges until something else
    // happened to rebuild the grid.
    //
    // Two keys, not one. The progress key is group-scoped, so switching groups
    // changes which key this card cares about — and the old key will never
    // change again. Watching groupIdKey as well means a group switch repaints
    // the badge immediately, instead of leaving the previous group's ticks on
    // screen until something else forced a rebuild.
    return ValueListenableBuilder(
      valueListenable: Hive.box(ProgressService.boxName).listenable(keys: [
        ProgressService().hiveKeyFor(categoryName),
        ProgressService.groupIdKey,
      ]),
      builder: (context, _, __) => _buildMark(),
    );
  }

  Widget _buildMark() {
    final CategoryProgress progress =
        ProgressService().forCategory(categoryName);
    final CategoryBadge badge = badgeFor(progress);

    if (badge == CategoryBadge.none) return const SizedBox.shrink();

    if (badge == CategoryBadge.visited) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFF95A5A5), width: 3),
        ),
      );
    }

    final int stars = starsFor(
      score: progress.quizScore,
      total: progress.quizTotal,
    );

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Icon(Icons.check, size: 22, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => Icon(
              index < stars ? Icons.star : Icons.star_border,
              size: 16,
              color: index < stars
                  ? const Color(0xFFF1C40F)
                  : const Color(0xFF95A5A5),
            ),
          ),
        ),
      ],
    );
  }
}
