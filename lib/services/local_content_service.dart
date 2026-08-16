import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'package:mozambique_app/model/conversation.dart';
import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/model/question.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/model/vocab.dart';

/// Loads all app content from the JSON + media files bundled in `assets/`,
/// bypassing Firestore and Firebase Storage entirely.
///
/// This exists so the app can be built and run without Firebase credentials.
/// It writes into the *same* Hive boxes, under the same keys, as
/// [DatabaseService] does after a Firestore sync — so nothing downstream
/// (views, view models, getters) can tell the difference.
class LocalContentService {
  final Box<List> _homeWordBox = Hive.box('home_words');
  final Box<List> _vocabWordBox = Hive.box('vocab_words');
  final Box<List> _questionBox = Hive.box('questions');
  final Box<List> _quizQuestionBox = Hive.box('quiz_questions');
  final Box<List> _convoBox = Hive.box('conversations');

  /// Every asset key declared in pubspec.yaml, used to resolve media paths
  /// without relying on exceptions for control flow.
  ///
  /// Cached statically: the manifest never changes at runtime, and
  /// [tryLoadAsset] is called per media file during a Firestore sync.
  static Set<String>? _cachedAssetKeys;

  static Future<Set<String>> _assetKeys() async {
    return _cachedAssetKeys ??= (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets()
        .toSet();
  }

  /// Media paths in the JSON that could not be resolved to a bundled asset.
  final Set<String> unresolvedPaths = {};

  bool get hasContent =>
      _homeWordBox.isNotEmpty &&
      _vocabWordBox.isNotEmpty &&
      _questionBox.isNotEmpty &&
      _quizQuestionBox.isNotEmpty &&
      _convoBox.isNotEmpty;

  /// Populates every Hive box from the bundled assets.
  ///
  /// [onProgress] receives 0.0-1.0 as each of the five content types finishes,
  /// matching the shape DatabaseService.syncContent reports.
  Future<void> loadIntoHive({void Function(double progress)? onProgress}) async {
    await _assetKeys(); // warm the manifest cache
    unresolvedPaths.clear();

    const totalSteps = 5;
    int completedSteps = 0;
    void onStepCompleted() {
      completedSteps++;
      onProgress?.call(completedSteps / totalSteps);
    }

    // Sequential rather than parallel: these are local disk reads, so there is
    // no latency to hide, and sequencing keeps peak memory down.
    await _loadHomeWords(onStepCompleted);
    await _loadVocabWords(onStepCompleted);
    await _loadLearnConvo(onStepCompleted);
    await _loadPracticeQuiz(onStepCompleted);
    await _loadPracticeConvo(onStepCompleted);

    if (unresolvedPaths.isNotEmpty) {
      log('LocalContentService: ${unresolvedPaths.length} media path(s) could '
          'not be resolved and were loaded as empty: '
          '${unresolvedPaths.take(5).join(", ")}...');
    }
    log('LocalContentService: content loaded from bundled assets.');
  }

  // ---------------- asset resolution ----------------

  /// Maps a JSON media path onto a real bundled asset key.
  ///
  /// The JSON paths were written against the Firebase Storage layout. Commit
  /// b622715 later moved the vocab media into `assets/audio/vocab_words/...`
  /// locally without rewriting the JSON, so ~20 quiz and conversation clips
  /// (e.g. `audio/face/Mouth.mp3`, `audio/practice_quiz/colors/Red.mp3`) only
  /// resolve under that folder. Try the literal path first, then there.
  static String? _resolveIn(Set<String> keys, String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;

    final String direct = 'assets/$relativePath';
    if (keys.contains(direct)) return direct;

    final List<String> parts = relativePath.split('/');
    if (parts.length >= 2) {
      final String relocated =
          'assets/audio/vocab_words/${parts[parts.length - 2]}/${parts.last}';
      if (keys.contains(relocated)) return relocated;
    }

    return null;
  }

  /// Loads a single bundled media file by its content-relative path, or returns
  /// null if this app does not ship that file.
  ///
  /// Used by [DatabaseService.fetchMedia] in hybrid mode: text comes from
  /// Firestore, but the media bytes are read from the bundle instead of
  /// Firebase Storage. That sidesteps the fact that the Storage bucket has no
  /// CORS policy, which makes Storage downloads impossible from a browser.
  static Future<Uint8List?> tryLoadAsset(String? relativePath) async {
    final String? key = _resolveIn(await _assetKeys(), relativePath);
    if (key == null) return null;

    final ByteData data = await rootBundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  /// Loads a media file as bytes, preferring an inline base64 blob when the
  /// JSON carries one. Returns empty bytes rather than throwing so that a
  /// single bad path cannot take down the whole load.
  Future<Uint8List> _loadBytes(String? relativePath, {String? base64Data}) async {
    if (base64Data != null && base64Data.isNotEmpty) {
      try {
        return base64Decode(base64Data.replaceAll(RegExp(r'^data.*,'), ''));
      } catch (err) {
        log('Failed to decode inline base64 for $relativePath: $err');
      }
    }

    final Uint8List? bytes = await tryLoadAsset(relativePath);
    if (bytes == null) {
      if (relativePath != null && relativePath.isNotEmpty) {
        unresolvedPaths.add(relativePath);
      }
      return Uint8List(0);
    }

    return bytes;
  }

  Future<dynamic> _readJson(String assetPath) async {
    return jsonDecode(await rootBundle.loadString(assetPath));
  }

  // ---------------- per-content-type loaders ----------------

  Future<void> _loadHomeWords(void Function() onStepCompleted) async {
    try {
      final List<dynamic> cards =
          await _readJson('assets/json/home_cards.json') as List<dynamic>;

      final List<HomeWord> homeWords = [];
      for (final dynamic entry in cards) {
        final Map<String, dynamic> item = entry as Map<String, dynamic>;

        // Home cards ship an inline base64 image; prefer it, fall back to file.
        homeWords.add(HomeWord(
          word: item['word'] ?? '',
          portuguese: item['portuguese'] ?? '',
          categoryName: item['categoryName'] ?? '',
          imageBytes: await _loadBytes(
            item['imagePath'],
            base64Data: item['imageBase64'],
          ),
          imagePath: item['imagePath'] ?? '',
          type: item['type'] ?? 'cards',
        ));
      }

      await _homeWordBox.put('home_cards', homeWords.cast<dynamic>());
    } catch (err, stack) {
      log('Error loading local Home Words: $err');
      log(stack.toString());
      rethrow;
    } finally {
      onStepCompleted();
    }
  }

  Future<void> _loadVocabWords(void Function() onStepCompleted) async {
    try {
      // vocab_words.slim.json is vocab_words.json with the inline base64
      // stripped (55.2 MB -> 34 KB). The blobs only duplicated files already
      // in assets/, and parsing them at startup dominated load time.
      final Map<String, dynamic> byCategory =
          await _readJson('assets/json/vocab_words.slim.json')
              as Map<String, dynamic>;

      for (final MapEntry<String, dynamic> category in byCategory.entries) {
        final List<VocabWord> words = [];

        for (final dynamic entry in category.value as List<dynamic>) {
          final Map<String, dynamic> item = entry as Map<String, dynamic>;

          // vocab_words.json carries 55 MB of base64 duplicating files already
          // in the tree, so read the files and ignore the inline blobs.
          words.add(VocabWord(
            categoryName: item['categoryName'] ?? category.key,
            word: item['word'] ?? '',
            portuguese: item['portuguese'] ?? '',
            imageBytes: await _loadBytes(item['imagePath']),
            audioBytes: await _loadBytes(item['audioPath']),
            imagePath: item['imagePath'] ?? '',
            audioPath: item['audioPath'] ?? '',
          ));
        }

        await _vocabWordBox.put(category.key, words.cast<dynamic>());
      }
    } catch (err, stack) {
      log('Error loading local Vocab Words: $err');
      log(stack.toString());
      rethrow;
    } finally {
      onStepCompleted();
    }
  }

  Future<void> _loadLearnConvo(void Function() onStepCompleted) async {
    try {
      final Map<String, dynamic> byCategory =
          await _readJson('assets/json/learn_convo.json') as Map<String, dynamic>;

      for (final MapEntry<String, dynamic> category in byCategory.entries) {
        final List<Question> questions = [];

        for (final dynamic entry in category.value as List<dynamic>) {
          final Map<String, dynamic> item = entry as Map<String, dynamic>;

          final List<Response> responses = [];
          for (final dynamic r in (item['responses'] as List<dynamic>? ?? [])) {
            final Map<String, dynamic> responseItem = r as Map<String, dynamic>;
            responses.add(Response(
              responseText: responseItem['responseText'] ?? '',
              audioPath: responseItem['audioPath'],
              emotion: responseItem['emotion'] ?? 'neutral',
              audioBytes: await _loadBytes(responseItem['audioPath']),
            ));
          }

          questions.add(Question(
            categoryName: category.key,
            questionText: item['questionText'] ?? '',
            audioPath: item['audioPath'],
            responses: responses,
            audioBytes: await _loadBytes(item['audioPath']),
          ));
        }

        await _questionBox.put(category.key, questions.cast<dynamic>());
      }
    } catch (err, stack) {
      log('Error loading local Learn Conversations: $err');
      log(stack.toString());
      rethrow;
    } finally {
      onStepCompleted();
    }
  }

  Future<void> _loadPracticeQuiz(void Function() onStepCompleted) async {
    try {
      final Map<String, dynamic> byCategory =
          await _readJson('assets/json/practice_quiz.json') as Map<String, dynamic>;

      for (final MapEntry<String, dynamic> category in byCategory.entries) {
        final List<QuizQuestion> questions = [];

        for (final dynamic entry in category.value as List<dynamic>) {
          final Map<String, dynamic> item = entry as Map<String, dynamic>;

          final List<QuizAnswer> answers = [];
          for (final dynamic a in (item['answers'] as List<dynamic>? ?? [])) {
            final Map<String, dynamic> answerItem = a as Map<String, dynamic>;
            answers.add(QuizAnswer(
              answerText: answerItem['answerText'] ?? '',
              isCorrect: answerItem['isCorrect'] ?? false,
              audioPath: answerItem['audioPath'] ?? '',
              audioBytes: await _loadBytes(answerItem['audioPath']),
            ));
          }

          questions.add(QuizQuestion(
            questionText: item['questionText'] ?? '',
            imageBytes: await _loadBytes(item['imagePath']),
            audioBytes: await _loadBytes(item['audioPath']),
            imagePath: item['imagePath'] ?? '',
            audioPath: item['audioPath'] ?? '',
            answers: answers,
          ));
        }

        await _quizQuestionBox.put(category.key, questions.cast<dynamic>());
      }
    } catch (err, stack) {
      log('Error loading local Practice Quiz: $err');
      log(stack.toString());
      rethrow;
    } finally {
      onStepCompleted();
    }
  }

  Future<void> _loadPracticeConvo(void Function() onStepCompleted) async {
    try {
      final Map<String, dynamic> byCategory =
          await _readJson('assets/json/practice_convo.json')
              as Map<String, dynamic>;

      for (final MapEntry<String, dynamic> category in byCategory.entries) {
        final List<dynamic> entries = category.value as List<dynamic>;
        if (entries.isEmpty) continue;

        // Matches the Firestore layout: the first record holds the scene image,
        // every record after it is a line of dialogue.
        final Map<String, dynamic> header = entries.first as Map<String, dynamic>;
        final String imagePath = header['imagePath'] ?? '';

        final List<ConvoLine> lines = [];
        for (final dynamic entry in entries.skip(1)) {
          final Map<String, dynamic> item = entry as Map<String, dynamic>;
          lines.add(ConvoLine(
            convoText: item['msgText'] ?? '',
            audioPath: item['audioPath'],
            audioBytes: await _loadBytes(item['audioPath']),
          ));
        }

        await _convoBox.put(category.key, [
          Conversation(
            categoryName: category.key,
            imagePath: imagePath,
            imageBytes: await _loadBytes(imagePath),
            conversationText: lines,
          ),
        ]);
      }
    } catch (err, stack) {
      log('Error loading local Practice Conversations: $err');
      log(stack.toString());
      rethrow;
    } finally {
      onStepCompleted();
    }
  }
}
