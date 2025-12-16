const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// ---- CONFIG ----
const SERVICE_ACCOUNT_PATH = '../../mozambique-app-firebase-adminsdk-fbsvc-434948f8b5.json';
const LOCAL_ASSETS_DIR = path.join(__dirname, '../../assets');
const STORAGE_ROOT = ''; // empty string means root of the bucket (i.e. mirror local structure)
const serviceAccount = require(SERVICE_ACCOUNT_PATH);

// ---- INIT FIREBASE ----
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: 'mozambique-app.firebasestorage.app'
});

const bucket = admin.storage().bucket();

// ---- UPLOAD FILES ----
/**
 * Recursively uploads a local directory to Firebase Storage, preserving the directory structure.
 * 
 * @param {string} localDir - The local directory to upload.
 * @param {string} storagePrefix - The prefix in the storage bucket where files will be uploaded.
 * @returns {Promise<void>}
 */
async function uploadDirectory(localDir, storagePrefix = '') {
    const entries = fs.readdirSync(localDir, { withFileTypes: true });

    for (const entry of entries) {
        const localPath = path.join(localDir, entry.name);
        // const storagePath = path.join(storagePrefix, entry.name).replace(/\\/g, '/'); // Normalize to forward slashes
        const storagePath = path.posix.join(storagePrefix, entry.name); // Use posix to ensure forward slashes

        if (entry.isDirectory()) {
            // Recursively upload subdirectory
            await uploadDirectory(localPath, storagePath);
        } else {
            // Upload file
            console.log(`Uploading ${localPath} to ${storagePath}...`);

            await bucket.upload(localPath, {
                destination: storagePath,
                resumable: false, // Disable resumable uploads for small files
                metadata: {
                    cacheControl: 'public,max-age=31536000', // Cache for 1 year
                }
            });
        }
    }
}

// ---- RUN ----
(async () => {
    try {
        console.log('Uploading assets to Firebase Storage...');
        await uploadDirectory(LOCAL_ASSETS_DIR, STORAGE_ROOT);
        console.log('Upload complete!');
    } catch (error) {
        console.error('Error uploading assets:', error);
    }
})();