/*
//  SERVICE ACCOUNT KEY NEEDED FOR FIREBASE AUTHENTICATION
//  MAKE SURE "type": "module" IS IN package.json
//  CHANGE THE PATHS TO YOUR LOCAL RELATIVE PATHS (vocab_words.json, home_cards.json)
*/

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { collection, doc, getFirestore, setDoc } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

import * as fs from 'fs';
// import * as path from 'path';
// import { fileURLToPath } from 'url';

// console.log(fileURLToPath(import.meta.url));
// console.log(path.dirname(fileURLToPath(import.meta.url)));

const vocabWordsJson = '../../assets/json/vocab_words.json';
const homeCardsJson = '../../assets/json/home_cards.json';
const questionJson = '../../assets/json/questions2.json';
const practiceQuizJson = '../../assets/json/practice_quiz.json';

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyA5qf9qx2MdA6rxkvahUIjOl0hRWerBwXY",
  authDomain: "mozambique-app.firebaseapp.com",
  projectId: "mozambique-app",
  storageBucket: "mozambique-app.firebasestorage.app",
  messagingSenderId: "465520899025",
  appId: "1:465520899025:web:21db1594d7d0b40c2926f0"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

const db = getFirestore(app);

// Read JSON files
const vocabWords = JSON.parse(fs.readFileSync(vocabWordsJson, 'utf-8'));
const homeCards = JSON.parse(fs.readFileSync(homeCardsJson, 'utf-8'));
const learnConvo = JSON.parse(fs.readFileSync(questionJson, 'utf-8'));
const practiceQuiz = JSON.parse(fs.readFileSync(practiceQuizJson, 'utf-8'));

// Collection name
const collectionName = 'cards';

// Document names
const vocabWordsDocumentName = 'categories';
const learnConvoDocumentName = 'learn_convo';
const practiceQuizDocumentName = 'practice_quiz';
const homeDocumentName = 'home';
const homeFieldName = 'home_cards'; // Field name for home cards

// Function to add data to Firestore
// This function will create a document in the specified collection with the given data
const addData = async (collectionName, documentName, data) => {
    try {
        const collRef = collection(db, collectionName);
        const docRef = doc(collRef, documentName);
        await setDoc(docRef, data, { merge: true });
    } catch (err) {
        try {
            // Remove imageBase64 and audioBase64 fields from data
            const newObj = { ...data };
            for (const key in newObj) {
                for (const item of newObj[key]) {
                    if (item.imageBase64) {
                        delete item.imageBase64;
                    }
                    if (item.audioBase64) {
                        delete item.audioBase64;
                    }
                }
            }

            const collRef = collection(db, collectionName);
            const docRef = doc(collRef, documentName);
            await setDoc(docRef, newObj, { merge: true });
        }
        catch (err) {
            console.error('Error creating document: ', err);
        }
    }
}

// Function to add data to Firestore
const addCardsToFirestore = async () => {
    // Add vocab words data to Firestore
    for (const category in vocabWords) {
        const items = vocabWords[category];
        const data = { [category]: items };
        await addData(collectionName, vocabWordsDocumentName, data);

        console.log(`Data for ${category} added successfully!`);
    }

    // Add learn conversation data to Firestore
    for (const category in learnConvo) {
        const items = learnConvo[category];
        const data = { [category]: items };
        await addData(collectionName, learnConvoDocumentName, data);

        console.log(`Data for ${category} added successfully!`);
    }
    
    // Add practice quiz data to Firestore
    for (const category in practiceQuiz) {
        const items = practiceQuiz[category];
        const data = { [category]: items };
        await addData(collectionName, practiceQuizDocumentName, data);

        console.log(`Data for ${category} added successfully!`);
    }

    // Add home cards data to Firestore
    const homeData = { [homeFieldName]: homeCards };
    await addData(collectionName, homeDocumentName, homeData);

    console.log(`Home data added successfully!`);
}

addCardsToFirestore()
    .then(() => {
        console.log('All data added successfully!');
    })
    .catch((err) => {
        console.error('Error adding data: ', err);
    });