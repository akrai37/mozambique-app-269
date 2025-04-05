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

const vocabWords = JSON.parse(fs.readFileSync(vocabWordsJson, 'utf-8'));
const homeCards = JSON.parse(fs.readFileSync(homeCardsJson, 'utf-8'));

const collectionName = 'cards';
const catDocumentName = 'categories';
const homeDocumentName = 'home';
const homeFieldName = 'home_cards';

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

const addCardsToFirestore = async () => {
    for (const category in vocabWords) {
        const items = vocabWords[category];
        const data = { [category]: items };
        await addData(collectionName, catDocumentName, data);

        console.log(`Data for ${category} added successfully!`);
    }

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