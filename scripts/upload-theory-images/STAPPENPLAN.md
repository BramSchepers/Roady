# Stappenplan: Afbeeldingen uploaden naar Firebase

## Overzicht

1. Firebase-credentials instellen  
2. Controleren dat alles klopt (map, Firestore, Sheet)  
3. Upload-script draaien  
4. Export naar Sheet  

---

## Stap 1: Firebase-credentials instellen

### 1a. Ga naar de scriptmap

```bash
cd c:\Users\brams\Desktop\Roady\scripts\upload-theory-images
```

### 1b. Maak een `.env` bestand

Maak in deze map een bestand `.env` (geen extensie).

**Optie A – Service account key (JSON)**

1. Firebase Console → Projectinstellingen → Service accounts  
2. Klik "Nieuwe privésleutel genereren" en download de JSON  
3. Hernoem het bestand naar `service-account-key.json`  
4. Zet het in `scripts/upload-theory-images/`  
5. In `.env`:

   ```
   GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
   ```

**Optie B – Zelfde waarden als Apps Script**

1. Google Sheet → Extensies → Apps Script → Projectinstellingen (tandwiel) → Scripteigenschappen  
2. Kopieer `PROJECT_ID`, `CLIENT_EMAIL` en `PRIVATE_KEY`  
3. In `.env`:

   ```
   PROJECT_ID=goroady-22332
   CLIENT_EMAIL=firebase-adminsdk-xxxxx@goroady-22332.iam.gserviceaccount.com
   PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   ```

Let op: `PRIVATE_KEY` moet tussen aanhalingstekens en moet `\n` bevatten voor newlines (zoals in Apps Script).

---

## Stap 2: Controleren vooraf

### 2a. Mapstructuur

Bestanden moeten staan in:

```
c:\Users\brams\Desktop\Roady\assets\images\theorie\chapter_00\webp\
```

Met namen zoals:

```
chapter_00_lesson_00_01_resultaat.webp
chapter_00_lesson_00_02_resultaat.webp
...
chapter_00_lesson_00_09_resultaat.webp
```

Het getal `01`, `02`, … correspondeert met de volgorde van lessen in Firestore (eerste les = 01, tweede = 02, enz.).

### 2b. Firestore-document

In Firebase Console → Firestore → `theoryChapters` moet er een document zijn met ID **`chapter_00`** (niet `inleiding`).

### 2c. Volgorde in Sheet / Firestore

De volgorde van de lessen in je Sheet (bij Import) = volgorde in Firestore.

- Rij 2 = les 1 → moet overeenkomen met `..._01_resultaat.webp`
- Rij 3 = les 2 → `..._02_resultaat.webp`
- enz.

Als de volgorde anders is, kun je het beste de rijen in je Sheet sorteren zodat ze overeenkomen met de bestandsnummers.

---

## Stap 3: Upload-script draaien

```bash
cd c:\Users\brams\Desktop\Roady\scripts\upload-theory-images
npm install
node upload.js
```

### Verwacht in de console

```
Upload (web/full): chapter_00_lesson_00_01_resultaat.webp
Upload (web/full): chapter_00_lesson_00_02_resultaat.webp
...
Firestore theoryChapters/chapter_00 bijgewerkt met 9 les-URLs.
Klaar.
```

### Als er een fout is

- **"Zet GOOGLE_APPLICATION_CREDENTIALS of PROJECT_ID..."** → controleer `.env` en de variabelen  
- **"Document theoryChapters/chapter_00 niet gevonden"** → Firestore-document-ID klopt niet  
- **"Geen lessen in chapter_00"** → eerst **Import** doen vanuit je Sheet  

---

## Stap 4: URLs in je Sheet zetten

1. Open je Google Sheet (TheorieRoady)  
2. Menu: **Roady → Theorie: Export naar blad**  
3. De export overschrijft het blad met data uit Firestore; kolom `imageUrl` zou nu gevuld moeten zijn  

---

## Checklist

| Stap | Controle |
|------|----------|
| 1 | `.env` bestaat met geldige credentials |
| 2 | Webp-bestanden in `assets/images/theorie/chapter_00/webp/` |
| 3 | Bestandsnamen eindigen op `_01_resultaat.webp`, `_02_resultaat.webp`, … |
| 4 | Firestore-document `theoryChapters/chapter_00` bestaat |
| 5 | Dat document bevat een `lessons`-array (vanuit Import) |
| 6 | Upload-script succesvol uitgevoerd |
| 7 | Export naar blad gedaan na de upload |

---

## Als de imageUrl-kolom nog leeg is

1. Controleer in **Firebase Console → Firestore** of `theoryChapters/chapter_00` een `lessons`-array heeft met `imageUrl`-velden.  
2. Controleer of de volgorde van lessen in Firestore overeenkomt met de bestandsnummers (01 = eerste les, 02 = tweede les, …).  
3. Controleer of je na het script opnieuw **Export naar blad** hebt gedaan (anders toont het blad nog oude data).
