import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view_model/home_search.dart';

HomeWord card(String categoryName, String portuguese) => HomeWord(
      word: categoryName,
      portuguese: portuguese,
      categoryName: categoryName,
      imageBytes: Uint8List(0),
      imagePath: '',
      type: 'cards',
    );

void main() {
  final colors = card('colors', 'Cores');
  final animals = card('animals', 'Animais');
  final greetings = card('greetings', 'Saudações');
  final requests = card('requests', 'Pedidos');

  final all = [colors, animals, greetings, requests];

  // greetings and requests have no Learn screen, so they are hidden there.
  final hidden = [greetings, requests];

  final vocab = {
    'colors': ['Vermelho', 'Verde', 'Azul'],
    'animals': ['Cabra', 'Galinha'],
  };

  List<HomeWord> learnSearch(String query) => filterHomeWords(
        allWords: all,
        hiddenCategories: hidden,
        vocabByCategory: vocab,
        searchText: query,
        isLearnScreen: true,
      );

  group('empty query', () {
    test('shows every visible Learn category', () {
      expect(learnSearch(''), [colors, animals]);
    });

    test('treats whitespace as empty', () {
      expect(learnSearch('   '), [colors, animals]);
    });

    test('does not apply the hidden filter on the Practice screen', () {
      final result = filterHomeWords(
        allWords: [greetings, requests],
        hiddenCategories: hidden,
        vocabByCategory: vocab,
        searchText: '',
        isLearnScreen: false,
      );
      expect(result, [greetings, requests]);
    });
  });

  group('matching', () {
    test('matches a category by its own title', () {
      expect(learnSearch('cor'), [colors]);
    });

    test('matches a category by a vocab word inside it', () {
      expect(learnSearch('vermelho'), [colors]);
    });

    test('is case insensitive', () {
      expect(learnSearch('VERMELHO'), [colors]);
      expect(learnSearch('CoReS'), [colors]);
    });

    test('trims surrounding whitespace', () {
      expect(learnSearch('  cabra  '), [animals]);
    });

    test('returns nothing when there is no match', () {
      expect(learnSearch('zzzz'), isEmpty);
    });

    test('can match more than one category', () {
      // 'a' appears in "Animais" and in several colour words.
      expect(learnSearch('a'), containsAll([colors, animals]));
    });
  });

  group('regressions', () {
    // The original expression was:
    //   title.contains(q) && hidden.any((c) => c.categoryName != cat)
    //     || vocab[cat]?.any((w) => w.contains(q)) == true
    //
    // With no parentheses, `&&` binds tighter than `||`, so a vocab-word match
    // short-circuited the visibility check entirely.
    test('a hidden category never appears, even if a vocab word matches', () {
      final vocabWithHidden = {
        ...vocab,
        'greetings': ['Vermelho'], // contrived: hidden category, matching word
      };

      final result = filterHomeWords(
        allWords: all,
        hiddenCategories: hidden,
        vocabByCategory: vocabWithHidden,
        searchText: 'vermelho',
        isLearnScreen: true,
      );

      expect(result, [colors]);
      expect(result, isNot(contains(greetings)));
    });

    // The old code used `any(... != ...)` — true whenever the hidden list held
    // two or more entries — where `every(... != ...)` was intended. That made
    // the visibility test pass for categories that should have been hidden.
    test('hidden categories stay hidden regardless of how many there are', () {
      for (final hiddenList in [
        [greetings],
        [greetings, requests],
      ]) {
        final result = filterHomeWords(
          allWords: all,
          hiddenCategories: hiddenList,
          vocabByCategory: vocab,
          searchText: 'a',
          isLearnScreen: true,
        );
        for (final h in hiddenList) {
          expect(result, isNot(contains(h)),
              reason: '${h.categoryName} should be hidden');
        }
      }
    });

    // The empty-query branch used `every` while the search branch used `any`,
    // so a category could appear or vanish based only on whether the search box
    // had text in it. Visibility must not depend on the query.
    test('the visible set with a query is a subset of the empty-query set', () {
      final baseline = learnSearch('').toSet();

      for (final query in ['a', 'cor', 'vermelho', 'cabra', 'e']) {
        expect(
          learnSearch(query).toSet().difference(baseline),
          isEmpty,
          reason: 'query "$query" surfaced a category that is hidden when the '
              'search box is empty',
        );
      }
    });
  });

  group('isVisibleOnLearn', () {
    test('is false only for categories in the hidden list', () {
      expect(isVisibleOnLearn(colors, hidden), isTrue);
      expect(isVisibleOnLearn(greetings, hidden), isFalse);
      expect(isVisibleOnLearn(requests, hidden), isFalse);
    });

    test('is true when nothing is hidden', () {
      expect(isVisibleOnLearn(greetings, const []), isTrue);
    });
  });

  group('matchesQuery', () {
    test('falls back to false for a category with no vocab', () {
      expect(matchesQuery(greetings, 'vermelho', vocab), isFalse);
    });

    test('matches on a partial word', () {
      expect(matchesQuery(colors, 'verm', vocab), isTrue);
    });
  });
}
