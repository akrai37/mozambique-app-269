import * as fs from 'fs';

const jsonFilePath = '../../assets/json/home_cards.json';
const jsonFilePath2 = '../../assets/json/vocab_words.json';
//const jsonFilePath3 = '../../assets/json/questions.json';

const jsonData = JSON.parse(fs.readFileSync(jsonFilePath, 'utf-8'));
const jsonData2 = JSON.parse(fs.readFileSync(jsonFilePath2, 'utf-8'));
//const jsonData3 = JSON.parse(fs.readFileSync(jsonFilePath3, 'utf-8'));

const imageToBase64 = (imagePath) => {
    imagePath = imagePath.replace("https://mozambique-app.web.app/", "");

    const relativePath = `../../${imagePath}`

    const base64Image = fs.readFileSync(relativePath, 'base64');
    return `data:image/png;base64,${base64Image}`;
}

const audioToBase64 = (audioPath) => {
    audioPath = audioPath.replace("https://mozambique-app.web.app/", "");

    const relativePath = `../../${audioPath}`

    const base64Audio = fs.readFileSync(relativePath, 'base64');
    return `data:audio/mpeg;base64,${base64Audio}`;
}

const convertJSONFormat = (data) => {
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

const convertJSONFormat2 = (data) => {
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

const convertedData = convertJSONFormat(jsonData);
//const convertedData2 = convertJSONFormat2(jsonData2);

// const convertedDataQR =
// {   requests: convertJSONFormatQR(jsonData3.requests),
//     Greeting: convertJSONFormatQR(jsonData3.Greeting)
// }

fs.writeFileSync(jsonFilePath, JSON.stringify(convertedData, null, 4), 'utf-8', (err) => {
    if (err) {
        console.error(`Error writing converted JSON file: ${err}`);
    } else {
        console.log(`Converted JSON file written: ${jsonFilePath}`);
    }
});
// fs.writeFileSync(jsonFilePath, JSON.stringify(convertedData, null, 4), 'utf-8', (err) => {
//     if (err) {
//         console.error(`Error writing converted JSON file: ${err}`);
//     } else {
//         console.log(`Converted JSON file written: ${jsonFilePath}`);
//     }
// });

// fs.writeFileSync(jsonFilePath2, JSON.stringify(convertedData2, null, 4), 'utf-8', (err) => {
//     if (err) {
//         console.error(`Error writing converted JSON file: ${err}`);
//     } else {
//         console.log(`Converted JSON file written: ${jsonFilePath2}`);
//     }
// });

