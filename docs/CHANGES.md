# Change Log — Improvement Project

A running record of what was changed and why. Newest phase last.

Companion documents: [AUDIT.md](AUDIT.md) (what was wrong on arrival),
[RUNNING.md](RUNNING.md) (how to build and run).

---

## Phase 1 — Run without Firebase

**Goal:** make the app buildable and runnable with no Firebase credentials, so
development can proceed at all.

**Problem it solves.** The app fetched all content from Firestore and Firebase
Storage. Running it required `android/app/google-services.json` and a live
`mozambique-app` Firebase project — neither of which was available. The
`com.google.gms.google-services` Gradle plugin also hard-fails the Android build
when that file is missing. Without solving this, nothing could be run, tested, or
demonstrated.

**Key insight.** The full content set was already committed to the repository,
and every view reads exclusively from Hive — no screen talks to Firestore
directly. So the network layer could be replaced without touching a single view
file.

### Changes

#### New: `lib/services/local_content_service.dart`
Loads all content from the JSON and media bundled in `assets/`, writing into the
*same* Hive boxes under the *same* keys that a Firestore sync produces. Nothing
downstream can tell the difference.

Handles the asset path drift documented in [AUDIT.md](AUDIT.md) §4 with a
fallback resolver: try the literal path, then try `assets/audio/vocab_words/`.
This resolves all 489 media references with zero misses.

Uses `AssetManifest` to check existence rather than exception handling, and
returns empty bytes for anything unresolvable so one bad path cannot take down
the whole load.

#### New: `assets/json/vocab_words.slim.json` (generated)
`vocab_words.json` is 55.2 MB, almost entirely base64 blobs duplicating PNG and
MP3 files already present in `assets/`. Parsing it at startup dominated load
time — badly on web, where it also has to cross the network.

Stripping the inline blobs gives an identical structure at **33.7 KB**, a
1,600× reduction. The original file is left untouched and simply is not bundled.

Regenerate with:
```bash
python3 -c "
import json
d=json.load(open('assets/json/vocab_words.json'))
slim={c:[{k:v for k,v in w.items() if k not in ('imageBase64','audioBase64')} for w in ws] for c,ws in d.items()}
json.dump(slim,open('assets/json/vocab_words.slim.json','w'),ensure_ascii=False,indent=1)
"
```

#### Modified: `pubspec.yaml`
Declared the content assets, which were previously undeclared and therefore not
bundled. The five content manifests are listed individually rather than
declaring `assets/json/` as a directory, which keeps the superseded 55 MB
`vocab_words.json` and the demo fixtures out of the build.

Bundled media totals 47.9 MB — 198 images (44.4 MB) and 291 audio clips (3.5 MB).

#### Modified: `lib/services/database_service.dart`
- Added a `useLocalContent` build flag (`--dart-define=LOCAL_CONTENT`,
  **defaulting to `true`**). The switch lives here rather than in `main.dart` so
  that `initializeDatabase` and `syncContent` route correctly no matter which
  screen calls them.
- `initializeDatabase` loads from bundled assets in local mode.
- `syncContent` reloads from bundled assets in local mode, so the moderator's
  *"Atualizar aplicativo"* button still works and — unlike the Firestore path —
  **reports honestly**, returning `false` on failure.
- **Bug fix:** `_firestore` is now `late`. See below.

#### Modified: `lib/main.dart`
- `Firebase.initializeApp()` is skipped entirely in local mode. No credentials
  are needed, and none are read.
- Replaced `path_provider` + `Hive.init(...)` with `Hive.initFlutter()`, which
  selects the right backing store per platform — documents directory on
  mobile/desktop, IndexedDB on web. The old call would have thrown on web.

### Bug fixed during this phase

**`DatabaseService` could not be constructed without a live Firebase connection.**

```dart
// before — runs on construction, throws if Firebase isn't initialized
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// after — deferred until something actually syncs from Firestore
late final FirebaseFirestore _firestore = FirebaseFirestore.instance;
```

Field initializers run when the object is built, so merely constructing
`DatabaseService` at `main.dart:80` threw `FirebaseException` — even though the
class has ~15 methods that only read local Hive data. Found by running the app;
it presents as a white screen with a `_TypeError` in the console.

### Reversibility

Nothing was deleted. The entire Firestore and Storage path remains intact and can
be re-enabled with one flag:

```bash
flutter run --dart-define=LOCAL_CONTENT=false
```

### Status

- `flutter analyze` — no errors; 14 remaining info-level lints, all pre-existing.
- App compiles and launches in Chrome with no Firebase credentials present, and
  with no exceptions in the console.
- **Asset pipeline verified end-to-end.** All 489 media references were fetched
  over HTTP from the running app: 435 resolved directly, 54 through the path
  drift fallback, 0 missing. Total 47.9 MB, matching the on-disk measurement
  exactly. The superseded 55 MB `vocab_words.json` correctly returns 404,
  confirming it is not bundled.
- **Visual rendering and audio playback confirmed working** in Chrome: the home
  grid renders, vocab cards show image + Portuguese word, and tapping the sound
  button plays the audio. The practice section works too.
- The `setSourceBytes`-on-web risk **did not materialise** — audio plays
  correctly, so no `AssetSource` migration was needed.

#### Note for anyone verifying assets by hand

Two quirks will make a naive check report false failures:

1. The Flutter dev server answers `HEAD` with 404 but `GET` with 200. Use `GET`.
2. Filenames containing spaces (e.g. `Common Actions.png`) are stored with the
   space URL-encoded, so fetching them over HTTP needs *double* encoding
   (`Common%2520Actions.png`). Inside the app this is a non-issue: the
   `AssetManifest` reports the literal space and `rootBundle.load` encodes it.

**Outcome:** the app runs end-to-end from bundled assets, with no Firebase
project, no credentials, and no network access.

---

## Phase 2 — Fix audit defects

**Goal:** fix the four user-facing defects found in the audit, and leave behind
tests that prove they stay fixed.

### 2.1 — Duplicate cards after a sync
`lib/view/home_screen.dart`

`_checkPractice()` now clears `_practiceCategories` and `_toRemove` before
refilling them. Both are `final` and were append-only, so each sync re-ran
`_loadContent()` and doubled the home grid.

### 2.2 — Sync no longer reports false success
`lib/services/database_service.dart`

The five `_sync*` methods now return `Future<bool>` instead of `Future<void>`,
returning `false` on exception or when the source collection is empty.
`syncContent` aggregates with `results.every(...)` and logs how many steps
failed.

Previously every step swallowed its own exception and `syncContent` returned
`true` unconditionally — so a total failure still showed *"Dados atualizados com
sucesso!"* to the moderator.

Worth noting: `InfoScreen` **already** had an error branch for a `false` return.
It was simply unreachable. The fix makes existing error handling work rather
than adding new UI.

### 2.3 — Quiz no longer assumes exactly three answers
`lib/view/quiz_options.dart`, `lib/view/quiz_screen.dart`

`QuizOptions` took `option1`, `option2`, and `option3` as three fixed required
parameters, which forced `quiz_screen` to index `answers[0..2]` blindly. It now
takes a single `List<QuizAnswer>` and derives its checkbox states and audio
players from the list length.

Fixing this at the widget's signature rather than guarding the call site means
the assumption cannot quietly return.

Questions with no answers are filtered in `_loadContent()` rather than in
`build()`, so the `isFirst`/`isLast` rounded-corner logic still compares against
the list that is actually rendered.

### 2.4 — Search filtering corrected and made testable
`lib/view_model/home_search.dart` (new), `lib/view/home_screen.dart`

The filtering logic was extracted out of `_HomeScreenState` into pure functions.
This fixed the bug and made it reachable by tests — the reason it survived this
long is that it was embedded in widget state where nothing could exercise it.

The original condition was:

```dart
title.contains(q) && toRemove.any((c) => c.categoryName != cat)
  || vocab[cat]?.any((w) => w.contains(q)) == true
```

Three distinct problems:
1. **Unparenthesised `&&`/`||`** — `&&` binds tighter, so a vocab-word match
   bypassed the visibility check entirely.
2. **`any(... != ...)` where `every(... != ...)` was meant** — true whenever the
   hidden list held two or more entries, so hidden categories passed the check.
3. **Asymmetry with the empty-query branch**, which used `every` — the same
   category could appear or vanish based only on whether the box had text in it.

Now visibility is applied to the pool up front, and matching is a parenthesised
`title || vocabWords`.

### Tests

`test/home_search_test.dart` — **16 tests, all passing.** Covers empty/whitespace
queries, title and vocab-word matching, case insensitivity, and a `regressions`
group targeting each of the three problems above.

The regression tests were validated by reimplementing the original expression
verbatim in a scratch file and confirming it exhibits both failures — so they
genuinely catch the bug rather than merely passing.

`test/widget_test.dart` was **deleted**. It was the unmodified Flutter counter
template, asserting on a `+` button and a counter that do not exist in this app;
it could never pass. Recoverable from git history if ever wanted.

### Status

- `flutter analyze` — no errors; 14 info-level lints, all pre-existing.
- `flutter test` — **16/16 passing** (was 0 passing, 1 failing).
- App relaunches and runs clean with no exceptions.

## Phase 3, Step 0 — Running against live Firebase

**Goal:** prove the app works against the real Firestore + Storage backend, not
just bundled files.

**Outcome:** working, in *hybrid* mode — text from Firestore, media from the
bundle. Verified visually: the `alphabet` category renders with Portuguese
letter names (Á, Bê, Cê…) and audio. That category exists only in Firestore, so
its presence is proof the text came from Firebase.

### Three bugs found by doing this

**1. The app could never sync from Firebase in a browser.**
`checkInternetConnection()` called `InternetAddress.lookup('google.com')` from
`dart:io`, which does not exist on web. It threw `UnsupportedError`, and the
method only caught `SocketException`, so it escaped and killed the whole sync
before a single document was fetched.

Fixed: skip the DNS probe on web (`kIsWeb`), catch broadly rather than only
`SocketException`, and guard the empty-list case from [AUDIT.md](AUDIT.md) §2.6
at the same time.

**2. Logging was invisible on web.**
Every message in the sync path used `dart:developer`'s `log()`, which does not
surface in `flutter run` output on web. A failure in a browser produced a blank
screen and complete silence — which is precisely why bug 1 went unnoticed.

Fixed: added `trace()`, which uses `debugPrint` (visible everywhere, stripped in
release) alongside `log()`. All sync-path logging routed through it.

**3. A populated Hive cache silently masked the content source.**
`initializeDatabase` skips syncing when the boxes already hold data. With a
cached database, the app looked healthy while never contacting Firestore at all
— no errors, no network calls, nothing to distinguish it from success. Several
"successful" hybrid test runs were actually serving stale local content.

Fixed: added `FORCE_SYNC`, which re-syncs regardless of cache state, so a test
of the Firebase path is genuinely a test of the Firebase path.

### Storage and CORS

Firebase Storage returns files with **no `Access-Control-Allow-Origin` header**,
so browsers refuse the download even though the file is publicly readable. The
fix is a CORS policy on the bucket — a change to infrastructure we do not own.

Worked around with `useLocalMedia` (`LOCAL_MEDIA`, defaulting to `kIsWeb`):
`fetchMedia()` checks the bundled assets first and only calls Storage when a
file is not bundled. It can therefore only ever *avoid* a download — it cannot
lose content, and it logs any fallback.

The 53 files that existed in Storage but not locally (the whole `alphabet`
category) were downloaded and bundled, so coverage is now 542/542. Downloading
is a read; nothing on the Firebase project was modified.

### Three content modes, all live

| Mode | Text | Media | Flags |
|---|---|---|---|
| Local | bundled | bundled | *(default)* |
| Hybrid | Firestore | bundled | `LOCAL_CONTENT=false` |
| Full Firebase | Firestore | Storage | `LOCAL_CONTENT=false LOCAL_MEDIA=false` |

Full Firebase needs a CORS policy on the bucket to work on web; it should work
as-is on Android.

### Known, not yet fixed

`initializeDatabase` is called from two places independently — `MyHomePage.initState`
and `HomeScreen._loadAllVocabWords` — so the sync runs twice. Harmless when a
cache short-circuits it, but under `FORCE_SYNC` the entire sync runs twice.

---

## Phase 3, Step 1 — The quiz produces a result

**Goal:** make the quiz measurable. Nothing else in the progress feature can be
built until a score exists.

### Single answer per question
`lib/view/quiz_options.dart`

Selection state went from `List<bool>` — every checkbox independently tickable —
to a single `int? _selectedIndex`.

Previously a learner could tick **all three answers at once**, including both
wrong ones, and see a green check sitting next to two red crosses. For a user
who cannot read and is learning what the interface even means, that is actively
misleading. A question has one answer, so the state is now one selection.

### Scoring records the first attempt
Selecting an answer fires `onFirstAnswer(bool wasCorrect)` exactly once, guarded
by `_hasReported`. Changing your mind afterwards still moves the highlight, but
does not change the score — otherwise everyone reaches 100% by trial and error
and the number means nothing.

`QuizScreen` collects these into `Map<int, bool> _answers`, keyed by question
index.

### A score you can read without reading
`lib/view/quiz_score.dart` (new)

One dot per question: empty outline for unanswered, green tick for correct, red
cross for wrong. Plus a `5 / 6` count, and a smiling face once every question is
answered — `bigSmile.png` for a perfect score, `smile.png` otherwise, both
already in the repo.

The dots carry the meaning; the number is for the moderator. This follows the
app's own stated principle — visuals and audio rather than text — which the
original navigation did not.

### Status

- `flutter analyze` — no errors, 14 pre-existing info lints.
- Verified in the browser: single-select works, dots fill in, face appears.

---

## Phase 3, Step 2 — Remembering what a group has done

**Goal:** the app forgot everything the moment it closed. A moderator running
weekly sessions had no record of which categories a group had covered, or how
they did.

### Progress storage
`lib/services/progress_service.dart` (new)

Hive first, Firestore second. A failed upload is logged and swallowed, because
the data is already safe on the device — the same offline-first argument the app
already makes for content, applied to a new data type. A tablet offline for
three weeks still records every session and uploads it when it next sees signal.

Stored as plain Maps in an untyped box rather than a new `@HiveType`, so no
generated adapter and no `build_runner`.

A quiz is only recorded once every question is answered, and a re-run keeps the
better score — practising can never make a group's record look worse.

Writes go to `progress_ankush`, a collection owned by this project. See
[FIREBASE.md](FIREBASE.md) for the separation rules.

### Badges on the home cards
`lib/view/category_badge_mark.dart` (new)

Nothing showed what a group had covered. Three states, by shape and colour
rather than words: nothing for untouched, a hollow grey ring for opened, a green
tick with stars for a finished quiz.

Which state applies comes from `badgeFor()` in `view_model/progress_summary.dart`,
which is unit tested. The widget only draws.

**Written test-first.** `test/progress_summary_test.dart` ran and failed with
`Method not found: badgeFor` before the implementation existed.

Writing the star thresholds as test sentences changed the design. Naming a case
*"a low score still earns one star for finishing"* forced the question of who
this is for, and produced a deliberately generous curve — any correct answer
earns a star, 60% earns two, 90% earns three. Implementation-first it would
likely have been an even 33/66/100 split, which grades people rather than
encouraging them.

---

## Phase 3, Step 3 — Groups, not devices

**The bug this fixed before it happened:** every tablet wrote to the same
Firestore document. With one device that is invisible. With two, the second
silently overwrites the first — worse than collecting nothing.

### Group identity

Each tablet generates a group id on first use, and progress is keyed by it in
both Hive and Firestore:

```
progress_ankush/{groupId}/categories/{category}
```

mirroring how the app's own content is laid out.

**No login.** The learners share the tablet and cannot read a sign-in screen, so
accounts would be unusable by the people meant to use them. The group is the
unit that matters, which is also what the deployment looks like: one device, one
group, a moderator running the session.

Progress recorded before groups existed is re-keyed under the first group, so a
tablet with history does not appear to lose it.

### A picker, not a one-way button

The first version was a "new group" button. Two problems surfaced immediately in
use, both raised in conversation rather than found in code:

1. A group meeting Monday may return Wednesday, and there was no way back — every
   session would start a new id and fragment their history.
2. A moderator in a hurry has to *remember* to press it. Forgetting silently
   merges two groups' records.

Replaced with a picker: choose who is here today from a list, most recently
active first, with relative timestamps. **Choosing is much harder to forget than
remembering.**

`GroupInfo` and `upsertGroup` were **written test-first**. One rule came out of
writing the tests rather than the code: a group with no timestamp must sort
**last**, or an incomplete record jumps to the top of the moderator's list.

### The badge refresh bug

Switching groups left the previous group's ticks on screen until you navigated
into a category and back.

The badge listened to one Hive key, `{groupId}::{category}`, computed once at
build time. Changing group changes *which key matters*, so the widget carried on
watching a key that would never change again.

**Every test passed. Hive was right. Firestore was right. Only the screen was
wrong** — and only if you switched group and looked without navigating first.
Found by using the app. Fixed by watching the group id as well.

---

## Phase 3, Step 4 — Filling the content gap

**The finding:** only 3 of 12 vocabulary categories had a quiz. Nine did not,
including `numbers` — the largest category in the app at 32 words. A learner
could study every one and never be tested. The app was roughly a quarter
complete against its own practice model, and no amount of interface work
changes that.

This reordered the plan. Polishing navigation for content that is 75% missing is
the wrong priority.

### Generating the quizzes
`tools/generate_quizzes.py`, `tools/push_quizzes.py` (new)

Nothing new had to be drawn or recorded. A question here is an image, a spoken
prompt and three spoken options — and every vocabulary word already has an
image, a Portuguese word and its own audio. Only the prompt was missing,
synthesised locally with macOS `say` using **Joana (pt_PT)**. European
Portuguese matters: Mozambique uses it, not Brazilian.

**54 questions, six per category.** Three details that matter:

- **Distractors come from the same category.** Picking `Cabra` out of {Cabra,
  Vermelho, Sete} tests nothing — the answer is guessable from the category
  alone.
- **Questions sample evenly** across a category rather than taking the first
  six, so `numbers` tests across its range instead of only 0–5.
- **The correct answer rotates through the option positions** — it lands
  18/18/18 across the three slots, so there is no positional habit to learn
  instead of the words.

### Separation

Written to `content_ankush`. The push script **refuses outright** if a target
path contains `app_content` or `dev_content` — a guard in code, not an
intention. Verified afterwards that both partner collections still hold exactly
three quiz categories.

The quiz sync reads the partner's collection first and ours second, filling only
categories they do not have. It can add, never override.

Result: **Prática went from 3 categories to 12, and 18 questions to 72.**

---

## Phase 3, Step 5 — Closing the loop

### Reflection card
`lib/view/reflection_card.dart` (new)

Finishing a quiz produced no moment of completion — the last dot filled in and
that was it.

Two levels: stars for the quiz just finished, and underneath a mark per category
the group has completed, so a session builds toward something visible. The
cumulative half only appears once more than one category is done.

No new logic — `SessionSummary` and `starsFor` were written test-first earlier
and already covered.

### Feedback popup
`lib/view_model/quiz_feedback.dart` (new)

A five-second summary when a quiz finishes: how it went, and what is worth
practising next. Colour-coded by tone.

Everything in it is real data — this attempt, the group's previous best in that
category, and their scores elsewhere. **Nothing is invented**, because a
moderator will notice encouragement that does not match what happened.

Aimed at the moderator, not the learners: it is text, and they cannot read. The
learners get the stars and the face.

**Written test-first**, failing with `Method not found: feedbackFor`. Two rules
came out of the tests:

- A first attempt is never framed as *"better than before"* — there is nothing
  to beat, and the claim would be false.
- Categories opened but never quizzed are ignored when picking what to practise;
  there is no result to judge.

The previous best has to be read *before* `recordQuizResult` runs, since that is
about to overwrite it.

### Duplication removed

The reflection card repeated the score and face already on the bar above it. The
bar is now only a progress indicator — dots and reset — and the card owns the
result. Caught on review, not by a test.

---

## Phase 3, Step 6 — Other fixes from using the app

**Audio could overlap.** Every card owned its own player and nothing ever called
`stop()`. Tapping three words played three Portuguese words at once. That
matters more here than elsewhere: the learners cannot read, so audio is not a
supplement to the content, it *is* the content — and the tablet is shared, so
several people reaching for it at once is normal rather than an edge case.
`AudioCoordinator` now stops the previous clip and seeks to zero, so re-tapping
restarts a word instead of resuming mid-way.

**A quiz could not be retaken.** The only route was to leave the screen and come
back, which resets in-memory state — so the capability existed but was
undiscoverable, and for a user who cannot read that means it did not exist.
Labelled `Reiniciar ⟲` to match the reset practice conversations already have.
Retrying cannot lower a group's record, since the better score is kept.

---

## Current state

| | Start | Now |
|---|---|---|
| Runs at all | No toolchain, no credentials | Three content modes |
| Tests | 0 passing, 1 failing | **65 passing** |
| Bugs fixed | — | **11** |
| Quiz categories | 3 | **12** |
| Quiz questions | 18 | **72** |
| Progress tracking | None | Per group, Hive + Firestore |

---

## Phase 3 — Picture-first navigation

*Not started.* Replaces the text search bar, addressing the design contradiction
in [AUDIT.md](AUDIT.md) §5: the app claims to serve non-readers while making
every navigation affordance text-only.
