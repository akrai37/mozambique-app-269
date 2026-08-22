import 'package:flutter/material.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/category_badge_mark.dart';

/// A fixed strip of category pictures down the left of the screen.
///
/// This exists because the app contradicted itself. Its own Info screen states
/// that it teaches through visuals and audio "instead of text", because the
/// learners cannot read — and then put a text search box at the top of every
/// screen as the primary way to get anywhere. A woman who cannot read cannot
/// type a Portuguese word she is currently learning, nor read the results.
///
/// So navigation becomes pictures: the same images already on the home cards,
/// each carrying the progress mark built for those cards. Tapping one jumps
/// straight there from anywhere, instead of going back to the grid and hunting.
///
/// Deliberately no text labels. The only readable things in here are the
/// progress marks, which are shape and colour.
class CategoryNavPanel extends StatelessWidget {
  /// Categories to show, in the same order as the grid.
  final List<HomeWord> categories;

  /// The category currently open, if any — highlighted so the user can see
  /// where they are.
  final String? currentCategory;

  /// Called with the tapped category.
  final void Function(HomeWord category) onSelect;

  /// Tapped when the logo at the top is pressed.
  final VoidCallback? onHome;

  /// Practice screens are dark; Learn screens are light.
  final bool isPractice;

  const CategoryNavPanel({
    super.key,
    required this.categories,
    required this.onSelect,
    this.currentCategory,
    this.onHome,
    this.isPractice = false,
  });

  static const double width = 148;

  @override
  Widget build(BuildContext context) {
    final Color background =
        isPractice ? const Color(0xFF2B3542) : const Color(0xFFECF0F1);
    final Color divider =
        isPractice ? const Color(0xFF4A5568) : const Color(0xFFD5DBDB);

    return Container(
      width: width,
      color: background,
      child: Column(
        children: [
          // Home. The logo is already the "go home" control in the top bar, so
          // this keeps the same meaning rather than inventing a new one.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: InkWell(
              onTap: onHome,
              child: Image(
                image: AssetImage(isPractice
                    ? 'assets/images/logos/diffeducation_transparent_dark.png'
                    : 'assets/images/logos/diffeducation_transparent.png'),
                height: 56,
              ),
            ),
          ),

          Divider(color: divider, height: 1),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final HomeWord category = categories[index];
                return _NavTile(
                  category: category,
                  isCurrent: category.categoryName == currentCategory,
                  isPractice: isPractice,
                  onTap: () => onSelect(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final HomeWord category;
  final bool isCurrent;
  final bool isPractice;
  final VoidCallback onTap;

  const _NavTile({
    required this.category,
    required this.isCurrent,
    required this.isPractice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color highlight =
        isPractice ? const Color(0xFF4A5568) : const Color(0xFFD6EAF8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isCurrent ? highlight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Center(
                  child: category.imageBytes.isNotEmpty
                      ? Image.memory(
                          category.imageBytes,
                          height: 84,
                          width: 84,
                          // Cache at display size: sixteen of these are on
                          // screen at once, and the source images are large.
                          cacheHeight: 168,
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 84,
                          color: isPractice ? Colors.white24 : Colors.black26,
                        ),
                ),

                // Same progress mark as the home cards, so the two read as one
                // system rather than two ways of saying the same thing.
                Positioned(
                  top: 0,
                  right: 0,
                  child: Transform.scale(
                    scale: 0.62,
                    alignment: Alignment.topRight,
                    child: CategoryBadgeMark(
                      categoryName: category.categoryName,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
