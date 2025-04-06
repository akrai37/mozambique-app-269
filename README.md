# DIFF EDUCATION Language Literacy App

A new Flutter project.

### Lib File Hierarchy
This offline-first Flutter application uses Hive to store its data locally, and Firestore to sync updates.

`/lib/models`: The blueprints for Hive objects (ie. category, vocab, q&a, quiz, conversation)
- To generate the *.g.dart files, run ```dart run build_runner build --delete-conflicting-outputs``` in terminal (if fields not updating in generated files, mark each field as required in constructor)

`/lib/repositories`: The functions that update/retrieve the Hive data directly

`/lib/viewmodel`: The bridge between model & view: functions that use the repositories to update the views

`/lib/assets`: The misc data, image, and audio files that will be intitially bundled with the project to ensure the users have access even without internet connection in the beginning; syncing with Firestore will update these

### Firebase Firestore:
There are 2 important steps that are needed to allow the app to fetch from Firestore as you debug:
- Place the Firebase Admin SDK private key (`mozambique-app-firebase-adminsdk-fbsvc-434948f8b5.json`) in the root of the folder
- Place the Google Services SDK (`google-services.json`) in `android/app`

### Firebase Hosting
`npm install -g firebase-tools` - installs a Firebase CLI

`firebase deploy` - deploy site to Firebase Hosting

### Steps For Adding New Media
1. Add images/audio to their respective folder inside `public/`
2. On Firestore, add a new image/audio object
3. Add the property `imagePath`/`audioPath` to it and give it a value of the hosted website's link appended by the media file's relative path from `public/` (i.e. `https://mozambique-app.web.app/images/body/Abdomen.png`)
4. (Optional) Use a script (e.g. `convertBase64ToJSON.js`, `JSON2Firestore.js`) to add the media file to the object's `imageBase64`/`audioBase64` property
5. Sync in the app, and everything should be updated!