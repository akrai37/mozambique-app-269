// Input:
// EnglishWord \t PortugueseWord \n

// Output:
// {
//  "word": {PortugueseWord},
//  "img": "assets/images/{EnglishWord}.png",
//}

const fs = require('fs');
// import * as fs from 'fs';
const path = require('path');
// import * as path from 'path';

const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

const inputFilePath = path.join(__dirname, 'mozambique-ify.txt');
const outputFilePath = path.join(__dirname, 'mozambique-ify_output.json');

const inputFile = fs.readFileSync(inputFilePath, 'utf-8');
const lines = inputFile.split('\n').filter(line => line.trim() !== '');
const output = [];

// Enter the category name here (user input)
let categoryName;

readline.question('Enter the category name: ', (input) => {
    categoryName = input.trim();
    readline.close();

    lines.forEach(line => {
        const [englishWord, portugueseWord] = line.split('\t').map(word => word.trim());
        if (englishWord && portugueseWord) {
            const formattedWord = {
                word: portugueseWord,
                img: `assets/images/${categoryName}/${englishWord}.png`
            };
            output.push(formattedWord);
        }
    });
    
    const jsonOutput = JSON.stringify(output, null, 4);
    fs.writeFileSync(outputFilePath, jsonOutput, 'utf-8');
    console.log(`Output written to ${outputFilePath}`);
});