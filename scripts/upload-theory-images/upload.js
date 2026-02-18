/**
 * Upload theory images (.webp only) to Cloudinary en update Firestore met URLs.
 *
 * Bestandsconventie:
 * - *_resultaat.webp of *_full.webp → imageUrlWeb (web, volledige resolutie)
 * - *_small.webp → imageUrl (mobiel, klein)
 * - Als alleen *_resultaat bestaat: gebruikt voor imageUrlWeb én imageUrl (fallback).
 *
 * Mapping: bestanden gesorteerd op les-nummer (01, 02, ...) → lessons[0], lessons[1], ...
 *
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

// Config: lokale map → Firestore document ID
const CHAPTER_MAPPING = {
  chapter_00: 'chapter_00',
  // chapter_01: 'volgend_hoofdstuk',
};

const CLOUDINARY_FOLDER = 'roady/theorie';

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

function getLessonIndex(filename) {
  const m =
    filename.match(/_(\d{2})_(?:resultaat|small|full)\.webp$/i) ||
    filename.match(/_(\d{2})\.webp$/);
  if (m) return parseInt(m[1], 10) - 1;
  return -1;
}

function isMobileFile(filename) {
  return /_small\.webp$/i.test(filename);
}

function isWebFile(filename) {
  return /_(resultaat|full)\.webp$/i.test(filename);
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
  const baseDir = resolve(__dirname, '../../assets/images/theorie');

  initCloudinary();
  await initFirebase();
  const db = getFirestore();

  for (const [chapterFolder, docId] of Object.entries(CHAPTER_MAPPING)) {
    const chapterPath = join(baseDir, chapterFolder);
    const webpPath = join(chapterPath, 'webp');

    let files;
    try {
      files = await readdir(webpPath);
    } catch (e) {
      console.warn(`Map niet gevonden: ${webpPath}, overslaan.`);
      continue;
    }

    const webpFiles = files.filter((f) => f.toLowerCase().endsWith('.webp'));
    if (webpFiles.length === 0) {
      console.warn(`Geen .webp bestanden in ${webpPath}`);
      continue;
    }

    const docRef = db.collection('theoryChapters').doc(docId);
    const docSnap = await docRef.get();
    if (!docSnap.exists) {
      console.warn(`Document theoryChapters/${docId} niet gevonden, overslaan.`);
      continue;
    }

    const data = docSnap.data();
    const lessons = data?.lessons || [];
    if (lessons.length === 0) {
      console.warn(`Geen lessen in ${docId}`);
      continue;
    }

    const byIndex = {};
    for (const f of webpFiles) {
      const idx = getLessonIndex(f);
      if (idx < 0) continue;
      if (!byIndex[idx]) byIndex[idx] = { mobile: null, web: null };
      if (isMobileFile(f)) byIndex[idx].mobile = f;
      else if (isWebFile(f)) byIndex[idx].web = f;
    }

    const indices = Object.keys(byIndex)
      .map(Number)
      .sort((a, b) => a - b);

    const urlsByIndex = {};
    for (const idx of indices) {
      const entry = byIndex[idx];
      const mobileFile = entry.mobile;
      const webFile = entry.web;
      let mobileUrl = '';
      let webUrl = '';

      if (webFile) {
        const localPath = join(webpPath, webFile);
        const publicId = `${chapterFolder}/${webFile.replace(/\.webp$/i, '')}`;
        console.log(`Upload (web/full): ${webFile}`);
        webUrl = await uploadToCloudinary(localPath, publicId);
      }
      if (mobileFile && mobileFile !== webFile) {
        const localPath = join(webpPath, mobileFile);
        const publicId = `${chapterFolder}/${mobileFile.replace(/\.webp$/i, '')}`;
        console.log(`Upload (mobile/small): ${mobileFile}`);
        mobileUrl = await uploadToCloudinary(localPath, publicId);
      }
      if (!mobileUrl) mobileUrl = webUrl;
      if (!webUrl) webUrl = mobileUrl;
      urlsByIndex[idx] = { mobile: mobileUrl, web: webUrl };
    }

    const newLessons = lessons.map((l, i) => {
      const urls = urlsByIndex[i];
      if (!urls) return l;

      const imageUrl = urls.mobile || urls.web || '';
      const imageUrlWeb = urls.web || urls.mobile || '';

      return { ...l, imageUrl, imageUrlWeb };
    });

    await docRef.update({
      lessons: newLessons,
    });

    console.log(
      `Firestore theoryChapters/${docId} bijgewerkt met ${indices.length} les-URLs.`
    );
  }

  console.log('Klaar.');
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
