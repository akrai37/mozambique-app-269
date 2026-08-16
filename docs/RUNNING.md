# Running the App

The app now runs with **no Firebase credentials**. All content is loaded from the
JSON and media bundled in `assets/`. See [CHANGES.md](CHANGES.md) for how and why,
and [FIREBASE.md](FIREBASE.md) for what Firebase does and what we have access to.

---

## One-time setup

Install the Flutter SDK. On macOS:

```bash
brew install --cask flutter
flutter --version   # verified against Flutter 3.44.8 / Dart 3.12.2
```

Then fetch dependencies from the repository root:

```bash
flutter pub get
```

That is the entire setup. No Xcode, no Android SDK, and no Firebase config files
are required for the web target.

---

## Run it

```bash
flutter run -d chrome
```

Chrome opens automatically. The first build takes a minute or two while Dart is
compiled to JavaScript; subsequent runs are much faster.

Useful keys while `flutter run` is attached:

| Key | Action |
|---|---|
| `r` | Hot reload — apply code changes in under a second |
| `R` | Hot restart — full restart, needed after changing fields or `main()` |
| `q` | Quit |

To see the available targets:

```bash
flutter devices
```

---

## Content source

Content selection is controlled by one build flag, `LOCAL_CONTENT`, which
**defaults to `true`**.

**Bundled local assets (default — no credentials needed):**
```bash
flutter run -d chrome
```

**Firestore + Firebase Storage (requires credentials):**
```bash
flutter run --dart-define=LOCAL_CONTENT=false \
            --dart-define=FIRESTORE_COLLECTION_NAME=dev_content
```

The Firestore path additionally requires:
- `android/app/google-services.json` (Google Services config)
- `mozambique-app-firebase-adminsdk-*.json` in the repository root, for the
  Node scripts in `lib/scripts/` only

Both are gitignored and must come from the Firebase console.

---

## Building for Android

Requires the Android SDK (via Android Studio), which is *not* needed for web.

Because the app no longer depends on Firebase by default, the
`com.google.gms.google-services` Gradle plugin — declared in `android/build.gradle`
and applied in `android/app/build.gradle` — will still fail the build if
`google-services.json` is absent. Either supply that file, or comment out both
plugin lines when building purely local.

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Checks

```bash
flutter analyze          # static analysis — expect 0 errors, 14 info lints
flutter test             # expect 16/16 passing
```

The 14 remaining analyzer lints are all pre-existing (`use_build_context_synchronously`
and `sized_box_for_whitespace`) and are informational, not errors.

---

## Troubleshooting

**White screen, `FirebaseException` in the console.** Something constructed a
Firebase handle while running in local mode. This was fixed by making
`DatabaseService._firestore` `late`; if it reappears, look for another eager
`FirebaseFirestore.instance` or `FirebaseStorage.instance` in a field
initializer.

**Content looks stale after changing the JSON or assets.** Hive caches the
loaded content, and `initializeDatabase` skips loading when the boxes are already
populated. Either press the *"Atualizar aplicativo"* button on the Info screen —
which reloads from assets in local mode — or clear browser storage for
`localhost` in Chrome DevTools (Application → Storage → Clear site data).

**Images or audio missing for one category.** Check the console for
`LocalContentService: N media path(s) could not be resolved`. The JSON media
paths were written against the old Firebase Storage layout; see
[AUDIT.md](AUDIT.md) §4.

**First web load is slow.** ~48 MB of media is decoded into Hive on first launch,
which on web means IndexedDB. This happens once; later launches read from the
cache.
