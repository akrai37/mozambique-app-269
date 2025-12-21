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
const learnConvoJson = '../../assets/json/learn_convo.json';
const practiceQuizJson = '../../assets/json/practice_quiz.json';
const practiceConvoJson = '../../assets/json/practice_convo.json';

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
const learnConvo = JSON.parse(fs.readFileSync(learnConvoJson, 'utf-8'));
const practiceQuiz = JSON.parse(fs.readFileSync(practiceQuizJson, 'utf-8'));
const practiceConvo = JSON.parse(fs.readFileSync(practiceConvoJson, 'utf-8'));

// Collection name
const collectionName = 'app_content';

// Document names
const vocabWordsDocumentName = 'vocab_words';
const learnConvoDocumentName = 'learn_convo';
const practiceQuizDocumentName = 'practice_quiz';
const practiceConvoDocumentName = 'practice_convo';
const homeDocumentName = 'home';
const homeFieldName = 'home_cards'; // Field name for home cards

/**
 * 
 * @param {*} item 
 * @returns {*} item without base64 fields
 */
const stripBase64 = (item) => {
    const copy = { ...item };
    delete copy.imageBase64;
    delete copy.audioBase64;

    return copy;
}

/**
 * Add data to Firestore
 * This function will create a document in the specified collection with the given data
 * 
 * @param {string} collectionName 
 * @param {string} documentName 
 * @param {string} rootCollectionName
 * @param {string} categoryName
 * @param {string} subcollectionName
 * @param {string} documentId
 * @param {*} items 
 */
const addData = async (collectionName, documentName, rootCollectionName, categoryName, subcollectionName, documentId, items) => {
    try {
        const categoryRef = doc(db, collectionName, documentName, rootCollectionName, categoryName);
        await setDoc(categoryRef, {
            name: categoryName,
        }, { merge: true });

        for (let i = 0; i < items.length; i++) {
            const item = stripBase64(items[i]);
            const itemRef = doc(categoryRef, subcollectionName, item[documentId]);
            await setDoc(itemRef, {
                ...item,
                order: i
            });
        }
    } catch (err) {
        console.error('Error creating document: ', err);
    }
}

/**
 * Add practice conversation data to Firestore
 * This function will create a document in the specified collection with the given data
 * 
 * @param {string} collectionName 
 * @param {string} documentName 
 * @param {string} rootCollectionName
 * @param {string} categoryName
 * @param {string} subcollectionName
 * @param {string} documentId1
 * @param {string} documentId2
 * @param {*} items 
 */
const addPracticeConvoData = async (collectionName, documentName, rootCollectionName, categoryName, subcollectionName, documentId1, documentId2, items) => {
    try {
        const categoryRef = doc(db, collectionName, documentName, rootCollectionName, categoryName);
        await setDoc(categoryRef, {
            name: categoryName,
        }, { merge: true });

        for (let i = 0; i < items.length; i++) {
            const item = stripBase64(items[i]);

            const subDocId = item[documentId1] || item[documentId2];

            const itemRef = doc(categoryRef, subcollectionName, subDocId.split('/').pop().split('.')[0]);
            await setDoc(itemRef, {
                ...item,
                order: i
            });
        }
    } catch (err) {
        console.error('Error creating document: ', err);
    }
}

/**
 * Add home data to Firestore
 * This function will create a document in the specified collection with the given data
 * 
 * @param {string} collectionName 
 * @param {string} documentName 
 * @param {string} rootCollectionName
 * @param {*} items 
 */
const addHomeData = async (collectionName, documentName, rootCollectionName, items) => {
    try {
        const docRef = doc(db, collectionName, documentName);
        
        for (let i = 0; i < items.length; i++) {
            const item = stripBase64(items[i]);

            const itemRef = doc(docRef, rootCollectionName, item.word);
            await setDoc(itemRef, {
                ...item,
                order: i
            });
        }
        
    } catch (err) {
        console.error('Error creating document: ', err);
    }
}

/**
 * Add all cards to Firestore
 */
const addCardsToFirestore = async () => {
    // Add vocab words data to Firestore
    for (const category in vocabWords) {
        await addData(collectionName, vocabWordsDocumentName, "categories", category, "words", "word", vocabWords[category]);

        console.log(`Data for ${category} added successfully!`);
    }

    // Add learn conversation data to Firestore
    for (const category in learnConvo) {
        await addData(collectionName, learnConvoDocumentName, "categories", category, "conversations", "questionText", learnConvo[category]);

        console.log(`Data for ${category} added successfully!`);
    }
    
    // Add practice quiz data to Firestore
    for (const category in practiceQuiz) {
        await addData(collectionName, practiceQuizDocumentName, "categories", category, "quiz", "questionText", practiceQuiz[category]);

        console.log(`Data for ${category} added successfully!`);
    }

    // Add practice conversation data to Firestore
    for (const category in practiceConvo) {
        await addPracticeConvoData(collectionName, practiceConvoDocumentName, "categories", category, "conversation", "imagePath", "audioPath", practiceConvo[category]);

        console.log(`Data for ${category} added successfully!`);
    }

    // Add home cards data to Firestore
    await addHomeData(collectionName, homeDocumentName, "categories", homeCards);

    console.log(`Home data added successfully!`);
}

(async () => {
    try {
        await addCardsToFirestore();
        console.log('All data added successfully!');
        process.exit(0); // Exit the process
    } catch (err) {
        console.error('Error adding data: ', err);
        process.exit(1); // Exit with error
    }
})();