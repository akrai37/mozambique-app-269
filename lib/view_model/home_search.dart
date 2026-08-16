import 'package:mozambique_app/model/home_word.dart';

/// Pure filtering logic for the home screen.
///
/// This lives outside the widget so it can be unit tested. The original
/// implementation was embedded in `_HomeScreenState` and carried a
/// boolean-precedence bug that no test could reach — see
/// `test/home_search_test.dart` for the regression cases.

/// Whether a Learn category should be shown at all.
///
/// [hiddenCategories] are the categories that have no Learn screen and so are
/// removed from the Learn grid entirely.
bool isVisibleOnLearn(HomeWord homeWord, List<HomeWord> hiddenCategories) {
  return hiddenCategories
      .every((hidden) => hidden.categoryName != homeWord.categoryName);
}

/// Whether a category matches [query], by its own title or by any vocab word
/// it contains.
///
/// [query] is expected to be already trimmed and lower-cased.
bool matchesQuery(
  HomeWord homeWord,
  String query,
  Map<String, List<String>> vocabByCategory,
) {
  if (homeWord.portuguese.toLowerCase().contains(query)) return true;

  return vocabByCategory[homeWord.categoryName]
          ?.any((portuguese) => portuguese.toLowerCase().contains(query)) ??
      false;
}

/// The categories to display, given the current search text.
///
/// Visibility is applied to the pool *before* matching. The previous version
/// combined the two as `title && any(...) || words`, which meant a vocab-word
/// match bypassed the visibility rule entirely, and used `any(... != ...)`
/// where `every(... != ...)` was intended.
List<HomeWord> filterHomeWords({
  required List<HomeWord> allWords,
  required List<HomeWord> hiddenCategories,
  required Map<String, List<String>> vocabByCategory,
  required String searchText,
  required bool isLearnScreen,
}) {
  final List<HomeWord> pool = isLearnScreen
      ? allWords.where((hw) => isVisibleOnLearn(hw, hiddenCategories)).toList()
      : List<HomeWord>.from(allWords);

  final String query = searchText.trim().toLowerCase();
  if (query.isEmpty) return pool;

  return pool
      .where((hw) => matchesQuery(hw, query, vocabByCategory))
      .toList();
}
