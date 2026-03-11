/**
 * Upload quiz question images to Cloudinary en update Firestore quizQuestions met imageUrl.
 *
 * Bestandsconventie:
 * - Plaats afbeeldingen in: assets/images/quiz/
 * - Bestandsnaam = Firestore document-ID + extensie, bv. ts_1.webp, gen_2.png
 * - Ondersteunde formaten: .webp, .png, .jpg, .jpeg
 *
 * Voorbeeld: ts_1.webp → upload naar Cloudinary, update quizQuestions/ts_1 met imageUrl
 *
 * .env: zelfde als upload-theory-images (GOOGLE_APPLICATION_CREDENTIALS of PROJECT_ID/CLIENT_EMAIL/PRIVATE_KEY,
 *         CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET).
 * Gebruik: npm run upload
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { v2 as cloudinary } from 'cloudinary';
import { readdir } from 'fs/promises';
import { join, resolve } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config();

const CLOUDINARY_FOLDER = 'roady/quiz';
const IMAGE_EXTENSIONS = /\.(webp|png|jpg|jpeg)$/i;

async function initFirebase() {
  const creds = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (creds) {
    const { readFile } = await import('fs/promises');
    const keyPath = resolve(__dirname, creds);
    const key = JSON.parse(await readFile(keyPath, 'utf8'));
    initializeApp({ credential: cert(key) });
  } else {
    const projectId = process.env.PROJECT_ID;
    const clientEmail = process.env.CLIENT_EMAIL;
    const privateKey = process.env.PRIVATE_KEY?.replace(/\\n/g, '\n');
    if (!projectId || !clientEmail || !privateKey) {
      throw new Error(
        'Zet GOOGLE_APPLICATION_CREDENTIALS of PROJECT_ID, CLIENT_EMAIL, PRIVATE_KEY in .env'
      );
    }
    initializeApp({
      credential: cert({
        projectId,
        clientEmail,
        privateKey,
      }),
    });
  }
}

function initCloudinary() {
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const apiKey = process.env.CLOUDINARY_API_KEY;
  const apiSecret = process.env.CLOUDINARY_API_SECRET;
  if (!cloudName || !apiKey || !apiSecret) {
    throw new Error(
      'Zet CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY en CLOUDINARY_API_SECRET in .env'
    );
  }
  cloudinary.config({
    cloud_name: cloudName,
    api_key: apiKey,
    api_secret: apiSecret,
  });
}

/**
 * Bepaalt de vraag-id uit bestandsnaam: "ts_1.webp" → "ts_1"
 */
function getQuestionId(filename) {
  if (!IMAGE_EXTENSIONS.test(filename)) return null;
  return filename.replace(IMAGE_EXTENSIONS, '');
}

async function uploadToCloudinary(localPath, publicId) {
  const result = await cloudinary.uploader.upload(localPath, {
    folder: CLOUDINARY_FOLDER,
    public_id: publicId,
    resource_type: 'image',
  });
  return result.secure_url;
}

async function run() {
  const quizImagesDir = resolve(__dirname, '../../assets/images/quiz');

  initCloudinary();
  await initFirebase();
  const db = getFirestore();

  let files;
  try {
    files = await readdir(quizImagesDir);
  } catch (e) {
    console.warn(
      `Map niet gevonden: ${quizImagesDir}. Maak de map aan en plaats daar bestanden zoals ts_1.webp (bestandsnaam = Firestore doc-id).`
    );
    process.exit(1);
  }

  const imageFiles = files.filter((f) => IMAGE_EXTENSIONS.test(f));
  if (imageFiles.length === 0) {
    console.warn(
      `Geen afbeeldingen (.webp, .png, .jpg) in ${quizImagesDir}. Bestandsnaam = vraag-id, bv. ts_1.webp`
    );
    process.exit(0);
  }

  const collection = db.collection('quizQuestions');
  let updated = 0;
  let skipped = 0;

  for (const filename of imageFiles) {
    const questionId = getQuestionId(filename);
    if (!questionId) continue;

    const docRef = collection.doc(questionId);
    const docSnap = await docRef.get();
    if (!docSnap.exists) {
      console.warn(
        `Document quizQuestions/${questionId} bestaat niet, overslaan: ${filename}`
      );
      skipped++;
      continue;
    }

    const localPath = join(quizImagesDir, filename);
    const publicId = questionId;
    console.log(`Upload: ${filename} → ${questionId}`);
    const imageUrl = await uploadToCloudinary(localPath, publicId);

    await docRef.update({ imageUrl });
    updated++;
  }

  console.log(
    `Klaar. ${updated} vragen bijgewerkt, ${skipped} overgeslagen (doc niet gevonden).`
  );
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
