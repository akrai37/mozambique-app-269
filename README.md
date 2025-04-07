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

### (JSON2Firestore.js)
1. Make sure the firebase library is installed (refer to **Installing Necessary Libraries**)
2. **Warning**: You may have to add `"type": "module",` in package.json to run this, but try without first
3. Modify JSON input file paths (`vocabWordsJson` and `homeCardsJson` variables)
4. Run `node JSON2Firestore.js`. Firestore should be updated. If a base64 string is too large to be uploaded, it will still upload the object with the online paths to the media.