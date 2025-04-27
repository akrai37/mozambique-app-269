// Input:
// EnglishWord \t PortugueseWord \n

// Output:
// {
//  "word": {EnglishWord},
//  "portuguese": {PortugueseWord},
//  "categoryName": {EnglishWord} lowercased and spaces replaced with underscores,
//  "imagePath": "assets/images/learn/{EnglishWord}.png",
//  "type": "cards"
// }
// 
// or
//
// {
//  "word": {EnglishWord},
//  "portuguese": {PortugueseWord},
//  "categoryName": {EnglishWord} lowercased and spaces replaced with underscores,
//  "imagePath": "assets/images/learn/{EnglishWord}.png",
//  "type": "conversation"
// }

const fs = require('fs');
// import * as fs from 'fs';
const path = require('path');
// import * as path from 'path';

const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

const inputFilePath = path.join(__dirname, 'home_cards_input.txt');
const outputFilePath = path.join(__dirname, '../../assets/json/home_cards.json');

const inputFile = fs.readFileSync(inputFilePath, 'utf-8');
const lines = inputFile.split('\n').filter(line => line.trim() !== '');
const output = [];

readline.question('Enter the conversation cards (English) separated by commas: ', (input) => {
    const conversationCards = input.split(',').map(card => card.trim().toLowerCase());
    readline.close();

    lines.forEach(line => {
        const [englishWord, portugueseWord] = line.split('\t').map(word => word.trim());

        if (englishWord && portugueseWord) {
            const formattedWord = {
                word: englishWord,
                portuguese: portugueseWord,
                categoryName: englishWord.toLowerCase().replace(/\s+/g, '_'),
                imagePath: `assets/images/learn/${englishWord}.png`,
                type: conversationCards.includes(englishWord.toLowerCase()) ? 'conversation' : 'cards',
            };
            output.push(formattedWord);
        }
    });
    
    const jsonOutput = JSON.stringify(output, null, 4);
    fs.writeFileSync(outputFilePath, jsonOutput, 'utf-8');
    console.log(`Output written to ${outputFilePath}`);
});