# DIFF EDUCATION Language Literacy App

This offline-first mobile app teaches Portuguese to non-literate mothers in rural Mozambique through visual and auditory learning, accommodating users with no reading or technology experience.

### Lib File Hierarchy
This offline-first Flutter application uses Hive to store its data locally, and Firestore to sync updates.

`lib/model/`: The blueprints for Hive objects (ie. category, vocab, q&a, quiz, conversation)
- To generate the *.g.dart files, run ```dart run build_runner build --delete-conflicting-outputs``` in terminal in root directory (if fields not updating in generated files, mark each field as required in constructor)

`lib/repositories/`: The functions that update/retrieve the Hive data directly

`lib/scripts/`: The scripts used to easily perform tasks at once (Check **Scripts** section for instructions)
- `convertToBase64inJSON.js`: Converts the media files to base64 strings and adds them to the JSON files
- `JSON2Firestore.js`: Uploads the JSON files to Firestore
- `mozambique-fy.js`: Converts the spreadsheet to JSON files
- `uploadAssetsToStorage.js`: Uploads the media files to Firebase Storage
- `vocab2audio.js`: Converts the vocab words to audio files using tts2mp3.com API

`lib/services/`: The functions that retrieve from the Firestore data and sync with the Hive data

`lib/view/`: The UI of the app

`lib/view_model`: The bridge between model & view: functions that use the repositories to update the views

### Firebase Firestore & Firebase Storage:
There are 2 important steps that are needed to allow the app to fetch from Firestore and Storage as you debug:
- Place the Firebase Admin SDK private key (`mozambique-app-firebase-adminsdk-fbsvc-434948f8b5.json`) in the root of the folder
- Place the Google Services SDK (`google-services.json`) in `android/app`

## Mobile App Deployment

### Building APK (Production)
1. In terminal, navigate to the root of the folder
2. Run `flutter build apk --release --dart-define=FIRESTORE_COLLECTION_NAME=app_content`
3. The APK file should be in `build/app/outputs/flutter-apk/app-release.apk`

### Building APK (Development)
1. In terminal, navigate to the root of the folder
2. Run `flutter build apk --debug --dart-define=FIRESTORE_COLLECTION_NAME=dev_content`
3. The APK file should be in `build/app/outputs/flutter-apk/app-debug.apk`

## Scripts
### Installing Necessary Libraries
1. Make sure Node.js and NPM are installed
2. In terminal, navigate to `lib/scripts/`
3. Run `npm install`

### Spreadsheet to JSON (mozambique-fy.js)

### Vocab Words to Audio Files (vocab2audio.js)
1. **Warning**: There is a limit from how many requests you can make in one day.
2. Use the structure seen in `assets/json/all_cards.json` to create a JSON of vocab words
3. Modify the path of that JSON file in `vocab2audio.js` (`allCardsPath` variable)
4. Modify all other relative paths if needed
5. Run `node vocab2audio.js`. `all_cards.json` should now contain the new output with the audio path as property for each word. The audio files should now be written to the output path
6. Note down any errors and which words were affected ("Usage Limit exceeded" is the most common error)
7. If the audio files are ready, copy them to `public/audio/...` in able for them to be hosted online (refer to **Firebase Hosting** section)

### Convert Media to Base64 and Put in JSON (convertToBase64inJSON.js)
1. **Note**: The script accounts for local paths and the hosted paths for the  `imagePath` and `audioPath` properties of the objects in the input JSON files.
2. **Warning**: You may have to add `"type": "module",` in package.json to run this, but try without first
3. Modify JSON input file paths (`jsonFilePath` variables)
4. Run `node convertToBase64inJSON.js`. The input JSON files should now be modified with the new base64 strings.

### Writing Card Data to Firestore (JSON2Firestore.js)
1. Make sure the firebase library is installed (refer to **Installing Necessary Libraries**)
2. **Warning**: You may have to add `"type": "module",` in package.json to run this, but try without first
3. Modify JSON input file paths (`vocabWordsJson` and `homeCardsJson` variables)
4. Run `node JSON2Firestore.js`. Firestore should be updated. If a base64 string is too large to be uploaded, it will still upload the object with the online paths to the media.

### Uploading Media Assets to Firebase Storage (uploadAssetsToStorage.js)
1. Make sure the firebase library is installed (refer to **Installing Necessary Libraries**)
2. **Warning**: You may have to add `"type": "module",` in package.json to run this, but try without first
3. Modify the local folder paths of the media files to be uploaded (`LOCAL_ASSETS_DIR` variable)
4. Run `node uploadAssetsToStorage.js`. The media files should now be uploaded to Firebase Storage.
