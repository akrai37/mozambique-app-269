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

const jsonFilePath = '../Documents/GitHub/mozambique_app/assets/json/all_cards2.json';

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

const jsonData = JSON.parse(fs.readFileSync(jsonFilePath, 'utf-8'));

const collectionName = 'cards';
const documentName = 'categories';

const addData = async (collectionName, documentName, data) => {
    try {
        const collRef = collection(db, collectionName);
        const docRef = doc(collRef, documentName);
        await setDoc(docRef, data, { merge: true });
    } catch (err) {
        console.error('Error creating document: ', err);
    }
}

const addCardsToFirestore = async () => {
    for (const category in jsonData) {
        const items = jsonData[category];
        const data = { [category]: items };
        await addData(collectionName, documentName, data);

        console.log(`Data for ${category} added successfully!`);
    }
}

addCardsToFirestore()
    .then(() => {
        console.log('All data added successfully!');
    })
    .catch((err) => {
        console.error('Error adding data: ', err);
    });