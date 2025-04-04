# mozambique_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Lib File hierarchy
This offline-first Flutter application uses Hive to store its data locally, and Firestore to sync updates.

/lib/models             The blueprints for Hive objects (ie. category, vocab, q&a, quiz, conversation)
                        To generate the *.g.dart files, run ```dart run build_runner build --delete-conflicting-outputs``` in terminal (if fields not updating in generated files, mark each field as required in constructor)
/lib/repositories       The functions that update/retrieve the Hive data directly
/lib/viewmodel          The bridge between model & view: functions that use the repositories to update the views
/lib/assets             The misc data, image, and audio files that will be intitially bundled with the project to ensure the users have access even    
                        without internet connection in the beginning; syncing with Firestore will update these

### Firebase Firestore:
There are 2 important steps that are needed to allow the app to fetch from Firestore as you debug:
- Place the Firebase Admin SDK private key (`mozambique-app-firebase-adminsdk-fbsvc-434948f8b5.json`) in the root of the folder
- Place the Google Services SDK (`google-services.json`) in `android/app`