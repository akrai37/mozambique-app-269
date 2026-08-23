# Firebase — How It Works Here

Quick reference for what Firebase does in this app, what we have access to, and
what is still undecided.

Project: **`mozambique-app`** · Console access granted to `arai4@scu.edu`
(verified 2026-08-06).

---

## The three pieces

| Piece | What it holds | Used today? |
|---|---|---|
| **Firestore** | The words — categories, vocab, questions, quizzes, conversations. Plus a *path* to each media file. | ✅ Yes |
| **Storage** | The actual `.png` and `.mp3` files. | ⚠️ Readable, but blocked in browsers — see below |
| **Auth** | Logins. | ❌ Not used, deliberately — see below |

---

## How content actually loads

Firestore does **not** store the pictures and sound. It stores the *path* to
them. Storage holds the real files.

```
1. App asks Firestore for the words
      → gets back text + a path like "images/vocab_words/numbers/0.png"

2. App asks Storage for that path
      → gets back the actual image/audio bytes

3. App saves the bytes into Hive (the on-device database)

4. Every launch after that reads from Hive — no internet needed
```

That is the whole offline-first design: **download once, work forever after.**
It is why the first launch needs internet and later ones do not.

The code doing step 2 is `fetchMedia()` in
[`lib/services/database_service.dart`](../lib/services/database_service.dart).
It handles two path shapes — a plain `http://…` URL, or a Storage path fetched
with `FirebaseStorage.instance.ref(path).getData()`.

---

## Why both Hive and Firebase

A fair question, since it looks like two databases doing one job. They are not
alternatives — they do different things.

**Firebase is the master copy, in the cloud. Hive is the copy on the tablet.**

The app talks to Firebase once, copies everything into Hive, and from then on
reads only from Hive.

```
First launch        needs internet -> downloads -> fills Hive
Every launch after  reads Hive -> no internet needed
"Atualizar"         moderator refreshes Hive from Firebase, when there is signal
```

Progress flows the same way in reverse:

```
Quiz finished  -> saved to Hive immediately (works offline)
               -> pushed to Firebase whenever a connection exists
```

So a tablet offline for three weeks still records every session, and it all
uploads the next time someone reaches a signal.

**Why the app cannot simply be "all Firebase":** it would need a connection
every time anyone opened it. In rural Mozambique that means it would not work
most days. Working without signal is the entire premise of the app, and Hive is
what delivers it. Take Hive away and you have software that only runs where
these users do not have internet.

---

## What a deployment actually needs

Measured against the current content set — 523 media files.

| | |
|---|---|
| App, with all content bundled | ~52 MB |
| Hive copy on the device after first sync | ~50 MB |
| **Realistic total on the tablet** | **under 150 MB** |

Which means:

- **One tablet**, roughly 150 MB free
- **Internet once**, for the first sync
- **No server, no laptop, no ongoing connection**

Nothing needs to be hosted or maintained by the non-profit day to day. Firebase
is only touched when content changes or results are uploaded.

---

## What we have confirmed

**Firestore — works.** Readable with no login at all. Checked 2026-08-06 via the
REST API:

| Collection | Contents |
|---|---|
| `app_content/home/categories` | 16 categories |
| `app_content/vocab_words/categories` | 13 categories |
| `dev_content/home/categories` | 16 categories |

Note this is **more than the local bundled content** — 16 online vs 15 local, and
13 vocab categories vs 12. There is an `alphabet` category on the server that is
not in the repo.

**Storage — readable, but not from a browser.** Files come back fine over plain
HTTP, so the bucket and paths are correct. The response carries **no
`Access-Control-Allow-Origin` header**, so a browser refuses to hand the bytes to
the page even though the file is public.

Fixing that means a CORS policy on a bucket this project does not own. Hybrid
mode works around it: text from Firestore, media from the app's bundled assets.
Native builds are unaffected and would use Storage normally.

---

## Where the config lives

| File | Purpose | In git? |
|---|---|---|
| `lib/firebase_options.dart` | What Dart passes to `Firebase.initializeApp()`. Web, Android, iOS. | ✅ Committed |
| `android/app/google-services.json` | Used **only** by the Android Gradle build. | ❌ Gitignored |
| `mozambique-app-firebase-adminsdk-*.json` | Admin key — used **only** by the Node scripts in `lib/scripts/`. | ❌ Gitignored |

Nothing extra is needed to read Firebase from the **web** build —
`firebase_options.dart` is already complete. `google-services.json` matters only
if building an Android APK.

**On secrecy:** the API keys in `firebase_options.dart` are *client identifiers*,
not passwords. They are meant to ship inside apps. Access is controlled by
Firestore/Storage **security rules** on the server. The genuinely secret file is
the Admin SDK key.

---

## Switching between local and Firebase

One flag, `LOCAL_CONTENT`, defaulting to `true`.

```bash
# Bundled local assets (default — no network, no credentials)
flutter run -d chrome

# Live Firestore + Storage
flutter run -d chrome --dart-define=LOCAL_CONTENT=false \
                      --dart-define=FIRESTORE_COLLECTION_NAME=dev_content
```

Use `dev_content` while developing and `app_content` for production. Both paths
are live in the code — neither was deleted.

---

## Login — decided against

The app has **no authentication**, and that is a decision rather than an
omission.

Both options were considered. Firebase Auth would give real accounts but needs a
connection for the first sign-in and adds a shared user pool to a project we do
not own. A local PIN would work offline but still puts a text field between a
learner and the content.

Neither survives the basic question of **who would type it**. The learners cannot
read a sign-in screen, and the tablet is shared rather than personal, so accounts
would be unusable by the people meant to use them.

**Group identity was built instead.** The tablet knows which group is using it,
the moderator picks from a list at the start of a session, and nobody types a
password. See [CHANGES.md](CHANGES.md), Phase 3 Step 3.

---

## Security rules — an open issue

There are **no `firestore.rules` or `storage.rules` in this repo**, and none
referenced in `firebase.json`. Whatever rules protect the project exist only in
the console — unversioned and unreviewable.

Reads and writes both work with no login at all, so the rules are currently
permissive. That is confirmed by behaviour, not by reading the config — the
console reports **"You do not have permission to view rules for this project"**
for the access this project has, which covers data but not security settings.

Testing what the database actually does is the stronger evidence anyway: the
rules text states intent, a successful unauthenticated write states fact.

It also means tightening the rules is not something that could be done from
here even if it were in scope. It belongs to whoever administers the project.
