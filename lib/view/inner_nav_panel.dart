import 'package:flutter/material.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/view/category_nav_panel.dart';
import 'package:mozambique_app/view/home_card.dart';
import 'package:mozambique_app/view/home_screen.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';

/// The category strip, for screens inside a category.
///
/// Only used on inner screens. On the home grid it would be a second copy of
/// what is already there — every category, as a picture, with the same badge.
/// Here it is the only way to reach another category without going back first.
///
/// Loads its own category list so each screen needs one line rather than
/// repeating the fetch-and-filter.
class InnerNavPanel extends StatefulWidget {
  /// The category currently open, highlighted in the strip.
  final String currentCategory;

  /// 'learn' or 'practice' — decides which categories are listed and where
  /// tapping one goes.
  final String type;

  const InnerNavPanel({
    super.key,
    required this.currentCategory,
    required this.type,
  });

  @override
  State<InnerNavPanel> createState() => _InnerNavPanelState();
}

class _InnerNavPanelState extends State<InnerNavPanel> {
  final DatabaseService _database = DatabaseService();
  List<HomeWord> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<HomeWord> all = await fetchHomeCards();

    final List<HomeWord> usable = all.where((word) {
      return widget.type == 'learn'
          ? _database.hasCategoryLearn(word.categoryName)
          : _database.hasCategoryPractice(word.categoryName);
    }).toList();

    if (!mounted) return;
    setState(() => _categories = usable);
  }

  @override
  Widget build(BuildContext context) {
    // Hold the width before the list arrives, so the content beside it does not
    // jump sideways once it loads.
    if (_categories.isEmpty) {
      return SizedBox(
        width: CategoryNavPanel.width,
        child: ColoredBox(
          color: widget.type == 'learn'
              ? const Color(0xFFECF0F1)
              : const Color(0xFF2B3542),
          child: const SizedBox.expand(),
        ),
      );
    }

    return CategoryNavPanel(
      categories: _categories,
      currentCategory: widget.currentCategory,
      isPractice: widget.type != 'learn',
      // Replace rather than push: jumping between categories from the strip
      // should not stack a screen every time, or Back walks through every
      // category the group happened to visit.
      onSelect: (category) =>
          openCategory(context, category, widget.type, replace: true),
      onHome: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(type: widget.type),
        ),
      ),
    );
  }
}
