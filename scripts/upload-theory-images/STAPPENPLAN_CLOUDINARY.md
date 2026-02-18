# Stappenplan: Afbeeldingen uploaden via Cloudinary

Afbeeldingen gaan naar **Cloudinary** (gratis hosting), de URLs worden in **Firestore** opgeslagen. Geen Firebase Storage nodig.

---

## Stap 1: Cloudinary-account aanmaken

1. Ga naar **[cloudinary.com](https://cloudinary.com)**
2. Klik op **Sign Up for Free**
3. Registreer met e-mail (of Google)
4. Na inloggen: ga naar je **Dashboard**

---

## Stap 2: Cloudinary-credentials kopiëren

Op het Dashboard zie je o.a.:

| Veld | Waar te vinden |
|------|----------------|
| **Cloud name** | Bovenaan, bijv. `dxxxxxx` |
| **API Key** | Onder "API Key" |
| **API Secret** | Klik "Reveal" naast API Secret om te tonen |

Je hebt deze drie waarden nodig voor `.env`.

---

## Stap 3: `.env` bijwerken

Open `scripts/upload-theory-images/.env` en voeg toe (of pas aan):

```
# Firebase (blijf gebruiken voor Firestore)
GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json

# Cloudinary (nieuw)
CLOUDINARY_CLOUD_NAME=jouw_cloud_name
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=jouw_api_secret
```

Vervang `jouw_cloud_name`, `123456789012345` en `jouw_api_secret` door de waarden uit je Cloudinary Dashboard.

Als je Firebase via PROJECT_ID/CLIENT_EMAIL/PRIVATE_KEY gebruikt, laat die regels staan en voeg de Cloudinary-regels eronder toe.

---

## Stap 4: Dependencies installeren

In een terminal:

```bash
cd c:\Users\brams\Desktop\Roady\scripts\upload-theory-images
npm install
```

De Cloudinary-package wordt dan geïnstalleerd.

---

## Stap 5: Controleren vooraf

- **Map:** `assets/images/theorie/chapter_00/webp/`
- **Bestanden:** `chapter_00_lesson_00_01_resultaat.webp`, `02`, `03`, … (alleen `.webp`)
- **Firestore:** document `theoryChapters/chapter_00` moet bestaan (van je Import)

---

## Stap 6: Upload-script uitvoeren

```bash
cd c:\Users\brams\Desktop\Roady\scripts\upload-theory-images
node upload.js
```

**Verwacht in de console:**
```
Upload (web/full): chapter_00_lesson_00_01_resultaat.webp
Upload (web/full): chapter_00_lesson_00_02_resultaat.webp
...
Firestore theoryChapters/chapter_00 bijgewerkt met 9 les-URLs.
Klaar.
```

---

## Stap 7: URLs in je Sheet zetten

1. Open je Google Sheet
2. **Roady > Theorie: Export naar blad**
3. De kolom `imageUrl` zou nu gevuld moeten zijn met Cloudinary-URLs

---

## Samenvatting flow

```
Lokale webp-bestanden
        ↓
   Upload-script
        ↓
    Cloudinary (hosting)
        ↓
   URLs in Firestore
        ↓
   Export naar Sheet (optioneel)
        ↓
   Flutter-app laadt images via URLs
```

---

## Checklist

| Stap | Gedaan |
|------|--------|
| Cloudinary-account aangemaakt | ☐ |
| Cloud name, API Key, API Secret in .env | ☐ |
| Firebase-credentials nog steeds in .env | ☐ |
| npm install uitgevoerd | ☐ |
| Webp-bestanden in chapter_00/webp/ | ☐ |
| node upload.js succesvol | ☐ |
| Export naar blad gedaan | ☐ |

---

## Veelvoorkomende fouten

- **"CLOUDINARY_CLOUD_NAME..."** → Cloudinary-regels ontbreken of zijn fout in `.env`
- **"Document theoryChapters/chapter_00 niet gevonden"** → Eerst Import vanuit Sheet doen
- **"Map niet gevonden"** → Controleren of `assets/images/theorie/chapter_00/webp/` bestaat met `.webp`-bestanden
