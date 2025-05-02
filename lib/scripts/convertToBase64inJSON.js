import * as fs from 'fs';

const jsonHomeCards = '../../assets/json/home_cards.json';
const jsonVocabWords = '../../assets/json/vocab_words.json';
const jsonLearnConvo = '../../assets/json/learn_convo.json';

const jsonDataHomeCards = JSON.parse(fs.readFileSync(jsonHomeCards, 'utf-8'));
const jsonDataVocabWords = JSON.parse(fs.readFileSync(jsonVocabWords, 'utf-8'));
const jsonDataLearnConvo = JSON.parse(fs.readFileSync(jsonLearnConvo, 'utf-8'));

// Converts image to base64
const imageToBase64 = (imagePath) => {
    imagePath = imagePath.replace("https://mozambique-app.web.app/", "");

    const relativePath = `../../${imagePath}`

    const base64Image = fs.readFileSync(relativePath, 'base64');
    return `data:image/png;base64,${base64Image}`;
}

// Converts audio to base64
const audioToBase64 = (audioPath) => {
    audioPath = audioPath.replace("https://mozambique-app.web.app/", "");

    const relativePath = `../../${audioPath}`

    const base64Audio = fs.readFileSync(relativePath, 'base64');
    return `data:audio/mpeg;base64,${base64Audio}`;
}

// Adds the base64 image to the Home Cards JSON
const convertJSONFormatHome = (data) => {
    return data.map(item => {
        if (item.imagePath.includes("https://mozambique-app.web.app/")) {
            item.imagePath = item.imagePath.replace("https://mozambique-app.web.app/", "");
        }

        return {
            categoryName: item.categoryName,
            word: item.word,
            portuguese: item.portuguese,
            imageBase64: imageToBase64(`assets/${item.imagePath}`),
            imagePath: `https://mozambique-app.web.app/${item.imagePath}`,
            type: item.type,
        };
    });
}

// Adds the base64 image and audio to the Vocab Words JSON
const convertJSONFormatVocabWords = (data) => {
    const updatedData = {};
    
    for (const category in data) {
        const items = data[category];
        updatedData[category] = items.map(item => {
            if (item.imagePath.includes("https://mozambique-app.web.app/")) {
                item.imagePath = item.imagePath.replace("https://mozambique-app.web.app/", "");
            }
            if (item.audioPath.includes("https://mozambique-app.web.app/")) {
                item.audioPath = item.audioPath.replace("https://mozambique-app.web.app/", "");
            }

            return {
                categoryName: item.categoryName,
                word: item.word,
                portuguese: item.portuguese,
                imageBase64: imageToBase64(`assets/${item.imagePath}`),
                audioBase64: audioToBase64(`assets/${item.audioPath}`),
                imagePath: `https://mozambique-app.web.app/${item.imagePath}`,
                audioPath: `https://mozambique-app.web.app/${item.audioPath}`,
            };
        });
    }

    return updatedData;
}

// Adds the base64 audio to the Learn Convo JSON
const convertJSONFormatQR = (data) => {
    return Object.fromEntries(
        Object.entries(data).map(([key, item]) => {
            return [key, {
                questionText: item.questionText,
                audioBase64: audioToBase64(`assets/${item.audioPath}`),
                audioPath: `https://mozambique-app.web.app/${item.audioPath}`,
                responses: [
                    {
                        emotion: item.responses[0].emotion,
                        responseText: item.responses[0].responseText,
                        audioBase64: audioToBase64(`assets/${item.responses[0].audioPath}`),
                        audioPath: `https://mozambique-app.web.app/${item.responses[0].audioPath}`
                    },
                    {
                        emotion: item.responses[1].emotion,
                        responseText: item.responses[1].responseText,
                        audioBase64: audioToBase64(`assets/${item.responses[1].audioPath}`),
                        audioPath: `https://mozambique-app.web.app/${item.responses[1].audioPath}`
                    }
                ]
            }];
        
        })
    );
}

const convertedData = convertJSONFormatHome(jsonDataHomeCards);
const convertedDataVocabWords = convertJSONFormatVocabWords(jsonDataVocabWords);

const convertedDataQR = {   
    requests: convertJSONFormatQR(jsonDataLearnConvo.requests),
    Greeting: convertJSONFormatQR(jsonDataLearnConvo.Greeting)
}

// Write the converted data to the same JSON file
fs.writeFileSync(jsonHomeCards, JSON.stringify(convertedData, null, 4), 'utf-8', (err) => {
    if (err) {
        console.error(`Error writing converted JSON file: ${err}`);
    } else {
        console.log(`Converted JSON file written: ${jsonHomeCards}`);
    }
});

// Write the converted data to the same JSON file
fs.writeFileSync(jsonVocabWords, JSON.stringify(convertedDataVocabWords, null, 4), 'utf-8', (err) => {
    if (err) {
        console.error(`Error writing converted JSON file: ${err}`);
    } else {
        console.log(`Converted JSON file written: ${jsonVocabWords}`);
    }
});

// Write the converted data to the same JSON file
fs.writeFileSync(jsonHomeCards, JSON.stringify(convertedDataQR, null, 4), 'utf-8', (err) => {
    if (err) {
        console.error(`Error writing converted JSON file: ${err}`);
    } else {
        console.log(`Converted JSON file written: ${jsonHomeCards}`);
    }
});