const fs = require('fs');
const path = require('path');

// Read all_cards.json
const allCardsPath = path.join(__dirname, '../../assets/json/all_cards.json');
const allCards = JSON.parse(fs.readFileSync(allCardsPath, 'utf-8'));

const processCards = async () => {
    const promises = [];

    for (const category in allCards) {
        allCards[category].forEach(async (card) => {
            const promise = (async() => {
                const portugueseWord = card.word;
                const englishWord = card.img.split('/').pop().split('.')[0];

                try {
                    // Get audio from ttsmp3.com
                    const response = await fetch("https://ttsmp3.com/makemp3_new.php", {
                        headers: {'content-type': 'application/x-www-form-urlencoded'},
                        // "body": "msg=Rosa&lang=Vitoria&source=ttsmp3",
                        body: new URLSearchParams({
                            msg: `${portugueseWord} <break time="1s"/>`, 
                            lang: 'Vitoria', 
                            source: 'ttsmp3'
                        }),
                        "method": "POST"
                    });
                    
                    const data = await response.json();

                    if (!data || data.Error) {
                        throw new Error(data.Error || 'Unknown error fetching audio');
                    }
            
                    const audioUrl = data.URL;
                    const audioFileName = `${englishWord}.mp3`;
            
                    // Create the category directory if it doesn't exist
                    const audioDir = path.join(__dirname, '../../assets/audio', category);
                    if (!fs.existsSync(audioDir)) {
                        fs.mkdirSync(audioDir, { recursive: true });
                    }
                    
                    const audioFilePath = path.join(__dirname, '../../assets/audio', category, audioFileName);
                    const audioResponse = await fetch(audioUrl);
                    // .buffer is not a function, use .arrayBuffer() instead
                    const audioBuffer = await audioResponse.arrayBuffer();
                    const audioBlob = Buffer.from(audioBuffer);
            
                    fs.writeFileSync(audioFilePath, audioBlob, 'binary', (err) => {
                        if (err) {
                            console.error(`Error writing audio file: ${err}`);
                        } else {
                            console.log(`Audio file written: ${audioFilePath}`);
                        }
                    });
            
                    // Update the card object with the audio file path
                    card.audio = `assets/audio/${category}/${audioFileName}`;
                } catch (err) {
                    console.error(`Error fetching audio for ${portugueseWord}: ${err}`);
                }
        
            })();

            promises.push(promise);
        });
    }

    await Promise.all(promises);
    
    const jsonOutput = JSON.stringify(allCards, null, 4);
    fs.writeFileSync(allCardsPath, jsonOutput, 'utf-8');
    console.log(`Output written to ${allCardsPath}`);
}

processCards().catch(err => {
    console.error(`Error processing cards: ${err}`);
});