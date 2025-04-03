import * as fs from 'fs';

const jsonFilePath = '../../assets/json/vocab_words.json';

const jsonData = JSON.parse(fs.readFileSync(jsonFilePath, 'utf-8'));
const updatedData = {};

const convertJSONFormat = (data) => {
    for (const category in data) {
        const items = data[category];
        updatedData[category] = items.map(item => {
            const englishWord = item.img.split('/').pop().split('.')[0];

            return {
                categoryName: category,
                word: englishWord,
                portuguese: item.word,
                imagePath: item.img,
                audioPath: item.audio,
            };
        });
    }

    return updatedData;
}

const convertedData = convertJSONFormat(jsonData);

fs.writeFileSync(jsonFilePath, JSON.stringify(convertedData, null, 4), 'utf-8', (err) => {
    if (err) {
        console.error(`Error writing converted JSON file: ${err}`);
    } else {
        console.log(`Converted JSON file written: ${outputFilePath}`);
    }
});