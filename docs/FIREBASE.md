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
| **Storage** | The actual `.png` and `.mp3` files. | ✅ Yes (untested) |
| **Auth** | Logins. | ❌ No — no login screen exists |

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

**Storage — not yet tested.** Config is correct (bucket
`mozambique-app.firebasestorage.app`, matching in all three places), but we have
not confirmed it actually serves files. If it does not, the app gets words but no
pictures or sound.

Likely snag on web: Storage downloads from a browser need **CORS** configured on
the bucket. Native builds are unaffected.

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

## Login / authorization — still to decide

The app has **no authentication today**. Nothing in the code touches Auth; it
reads the database anonymously.

The decision that matters is **who logs in**. The learners cannot read, so a
login screen is useless to them. It would be for **moderators** — to gate things
like the sync button.

Two options:

**Firebase Auth** — real accounts (email/password). Needs internet for the first
login, then remembers the session. The project already exists, so this is easy to
add. Better if you want real identity or to lock down who can change content.

**Local PIN** — a code stored on the device. No Firebase, no network, works fully
offline. Better fit for the actual deployment: a shared tablet in a rural area
with a moderator who mostly works offline.

**Not yet decided.** See [CHANGES.md](CHANGES.md) for status.

---

## Security rules — an open issue

There are **no `firestore.rules` or `storage.rules` in this repo**, and none
referenced in `firebase.json`. Whatever rules protect the project exist only in
the console — unversioned and unreviewable.

The fact that Firestore reads work with no login at all means the rules currently
allow public reads. That is fine for content meant to be public, but worth
knowing before adding anything user-specific.
