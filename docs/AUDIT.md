# Code Audit — Inherited Codebase

Findings from a cold read of the repository as handed over, before any changes
were made. Every item here is **pre-existing**, not introduced by this project.

Audited at commit `d092f53` (version 1.2.3+7). ~4,400 lines of Dart.

This document is a **point-in-time record of the code as received** — the
findings below describe the original state, not the current one. See the
resolution table for what has since been addressed, and
[CHANGES.md](CHANGES.md) for how.

## Resolution status

| # | Finding | Status |
|---|---|---|
| 2.1 | Duplicate cards after sync | ✅ Fixed (Phase 2) |
| 2.2 | Sync always reports success | ✅ Fixed (Phase 2) |
| 2.3 | Quiz crashes without exactly 3 answers | ✅ Fixed (Phase 2) |
| 2.4 | Boolean-precedence bug in search | ✅ Fixed (Phase 2) + regression tests |
| 2.5 | `BuildContext` across async gaps | ⬜ Open — 8 analyzer warnings |
| 2.6 | Unguarded `connectivityResult[0]` | ✅ Fixed (Phase 3 Step 0) |
| 2.8 | `InternetAddress.lookup` breaks all syncing on web | ✅ Fixed (Phase 3 Step 0) |
| 2.9 | Sync logging invisible on web | ✅ Fixed (Phase 3 Step 0) |
| 2.7 | Eager Firebase handle | ✅ Fixed (Phase 1) |
| §3 | Dead `repositories/` layer | ⬜ Open |
| §3 | `_visibleMessages` never rendered | ⬜ Open |
| §3 | Schema drift (`hasPractice` etc.) | ⬜ Open |
| §3 | No test coverage | ✅ Addressed — 16 tests added, broken template removed |
| §4 | Asset path drift (20 files) | ✅ Worked around by the loader's fallback resolver |
| §5 | Text-only navigation for non-readers | ⬜ Open — planned for Phase 3 |
| §6 | Repo hygiene / missing Firestore rules | ⬜ Open |

---

## 1. What the app is

An offline-first Flutter tablet app that teaches Portuguese to non-literate
mothers in rural Mozambique through images and audio rather than text. Built by
Santa Clara University undergraduates (May 2024 – June 2025) in partnership with
the DIFF EDUCATION non-profit and SCU's Frugal Innovation Hub.

Content lives in Firebase (Firestore + Storage). On first launch the app
downloads everything — text, images, and audio as raw bytes — into local Hive
boxes, then runs entirely offline. A moderator re-syncs manually from the Info
screen.

**Architecture, layer by layer:**

| Layer | Location | Role |
|---|---|---|
| Models | `lib/model/` | 5 Hive types (typeIds 1–8) + generated adapters |
| Service | `lib/services/database_service.dart` | 663 lines; Firestore sync, media fetch, all Hive getters |
| View models | `lib/view_model/fetch_cards.dart` | Thin Hive-first-then-sync wrappers |
| Views | `lib/view/` | `StatefulWidget` + `FutureBuilder` + `setState`; no state-management package |
| Scripts | `lib/scripts/` | Node.js content pipeline (spreadsheet → JSON → base64 → Firebase) |

**Key structural fact:** every view reads exclusively from Hive. No screen ever
talks to Firestore directly. This is what makes the data source swappable.

---

## 2. Defects

Ranked by likelihood of affecting a real user.

### 2.1 Duplicate cards after an in-app sync
`lib/view/home_screen.dart:27-28`

`_practiceCategories` and `_toRemove` are declared `final` and `_checkPractice()`
only ever appends to them. The Info screen's sync callback re-runs
`_loadContent()`, so both lists grow on every sync and the home grid duplicates.

### 2.2 Sync always reports success
`lib/services/database_service.dart`

Each of the five `_sync*` methods catches its own exceptions and only logs them.
`syncContent` then returns `true` unconditionally. If all five steps fail — the
exact scenario in a low-connectivity deployment — the moderator still sees
*"Dados atualizados com sucesso!"*

This is the most consequential defect, because it makes every other sync failure
invisible to the only person who could act on it.

### 2.3 Quiz crashes without exactly three answers
`lib/view/quiz_screen.dart:107-109`

Indexes `answers[0]`, `[1]`, `[2]` directly. All 18 current questions have three,
so this is latent — it fires the moment anyone authors a two-option question.

### 2.4 Boolean-precedence bug in home search
`lib/view/home_screen.dart:74-78`

Mixes `&&` and `||` with no parentheses, and tests
`_toRemove.any((c) => c.categoryName != homeWord.categoryName)` — "any that don't
match," which is true whenever `_toRemove` holds two or more entries. The
empty-search branch at line 68 uses `every(... != ...)`, which is the correct
form. Searching likely resurfaces categories meant to stay hidden.

### 2.5 `BuildContext` used across async gaps
`lib/services/database_service.dart`, `lib/view/info_screen.dart`

Navigation happens after `await`s. `info_screen.dart` guards its `Navigator.pop`
with `context.mounted` but not the `ScaffoldMessenger` call immediately after.
`flutter analyze` reports 8 instances.

### 2.6 Unguarded index in the connectivity check
`lib/services/database_service.dart`

Reads `connectivityResult[0]` without checking for an empty list, then falls back
to a DNS lookup of `google.com` — which restrictive networks block, producing a
false "offline."

### 2.7 Eager Firebase handle makes the class unconstructible offline
`lib/services/database_service.dart`

`final FirebaseFirestore _firestore = FirebaseFirestore.instance;` is a *field
initializer*, so it runs on construction. `FirebaseFirestore.instance` throws if
`Firebase.initializeApp()` hasn't run. The practical effect: `DatabaseService`
cannot be constructed at all without a live Firebase connection — including for
the ~15 methods on it that only read local Hive data.

*Found by running the app; see [CHANGES.md](CHANGES.md) for the fix.*

---

## 3. Dead and drifting code

- **The entire `lib/repositories/` layer is unreachable.** `vocab_repo.dart:9`
  opens `Hive.box<VocabWord>('vocab_words')`, but `main.dart:43` opens that box
  as `Box<List>` — it would throw a type error on first use.
  `question_response_repo.dart` is 100% commented out. `crud_test.dart` is a
  scratch script. Nothing imports any of them.
- **`_visibleMessages`** in `lib/view/practice_convo.dart` is appended to and
  popped from, but never rendered — the build loop reads `_messages` directly.
- **Schema drift.** `HomeWord.hasPractice` exists in the model and generated
  adapter but is never populated from Firestore. Recent commits added `hasQuiz`,
  `hasLearnConvo`, and `hasPracticeConvo` to `home_cards.json`; no Dart code
  reads those either. Availability is instead recomputed at runtime from Hive
  box membership.
- **No test coverage.** `test/widget_test.dart` is still the untouched Flutter
  counter template — it asserts on a `+` button this app does not have.

---

## 4. Asset path drift

20 media files are referenced at paths that do not exist on disk:

```
JSON says:  audio/face/Mouth.mp3
Actually:   assets/audio/vocab_words/face/Mouth.mp3

JSON says:  audio/practice_quiz/colors/Red.mp3
Actually:   assets/audio/vocab_words/colors/Red.mp3
```

Commit `b622715` ("Move vocab words images to own folder") reorganized the local
tree without rewriting the JSON. This went unnoticed because Firebase Storage
still served the old layout — the app never read the local files. Any attempt to
run from bundled assets hits it immediately.

---

## 5. Architectural observations

**Sync is all-or-nothing and non-incremental.** Every sync re-downloads every
image and audio file. No timestamps, no ETags, no versioning. For an app whose
entire premise is unreliable rural connectivity, this is the most significant
design weakness — and it is why defect 2.2 matters so much.

**The service layer carries everything.** `DatabaseService` is 663 lines while
`view_model/` is a thin passthrough and `repositories/` is vestigial. The MVVM
structure is nominal rather than real.

**The app contradicts its own design principle.** The Info screen states the app
"uses visuals and audio    instead of text." The content honours that. The
navigation does not: the search box hint `Procurar...`, the section headings
`Aprender` / `Prática`, the `Information` header, and the sync button are all
text-only. A user who cannot read cannot use any of them.

The search bar is the sharpest case — it sits atop every screen as the primary
affordance and requires the user to read a hint, spell a Portuguese word she is
currently learning, and read the filtered results.

---

## 6. Repository hygiene and security

- `.git` is 144 MB. `assets/images/vocab_words/` and `public/images/` hold
  byte-identical copies of the same artwork (bundled vs. Firebase-hosted), and
  `vocab_words.json` is a 55 MBdo base64 duplicate of files already in the tree —
  the same images are committed three times over.
- Most of `assets/` was not declared in `pubspec.yaml`; only the
  Prac-Body/Prac-Face/logo sets shipped in the APK.
- `.DS_Store` is tracked, along with `Database Structure.pdf` and script scratch
  files.
- **No `firestore.rules` or `storage.rules` in the repo**, and none referenced in
  `firebase.json`. The app reads Firestore unauthenticated, so whatever access
  rules protect that project exist only in the console — unversioned and
  unreviewable.
- Credentials are handled correctly: the Admin SDK key and `google-services.json`
  are properly gitignored. `firebase_options.dart` is committed, which is fine —
  those identifiers are public by design.
