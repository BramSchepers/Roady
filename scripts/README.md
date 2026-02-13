# Roady – Google Sheets koppeling

Met dit Apps Script kun je de Firestore-data (theorie én oefenvragen) beheren via Google Sheets.

## Setup

1. Maak een Google Spreadsheet (of gebruik een bestaande).
2. Ga naar **Extensies > Apps Script**.
3. Plak de inhoud van `appscript` in `Code.gs` (of maak een bestand en plak het daar).
4. Stel **Script-eigenschappen** in (Extensies > Apps Script > Projectinstellingen > Scripteigenschappen):
   - `PROJECT_ID`: je Firebase project-ID
   - `CLIENT_EMAIL`: e-mail van je service account (Firebase Console > Projectinstellingen > Service accounts)
   - `PRIVATE_KEY`: private key van het service account (met `\n` voor newlines)

5. Herlaad het spreadsheet. Er verschijnt een **Roady**-menu in de menubalk.

## Oefenvragen

### Werkwijze

1. Maak een nieuw blad (tab) voor de oefenvragen, of gebruik het actieve blad.
2. Kies **Roady > Oefenvragen: Export naar blad** om alle vragen uit Firestore te laden.
3. Bewerk de vragen in Sheets.
4. Kies **Roady > Oefenvragen: Importeer van blad** om wijzigingen terug naar Firestore te schrijven.

### Kolommen (oefenvragen)

| Kolom | Beschrijving | Verplicht |
|-------|--------------|-----------|
| id | Unieke ID (gebruikt als document-ID in Firestore) | Ja |
| text | Vraagtekst | Ja |
| imageUrl | URL van afbeelding (optioneel) | Nee |
| options | Antwoordopties, **één per regel** in dezelfde cel | Ja |
| correctOptionIndex | Index van het juiste antwoord (0 = eerste optie) | Ja |
| explanation | Uitleg bij het correcte antwoord | Nee |
| type | `multipleChoice`, `yesNo` of `hazardPerception` | Nee (default: multipleChoice) |
| category | `traffic_signs`, `general`, `hazard` | Nee (default: general) |
| pointsDeductionIfWrong | Aftrek bij fout (1 of 5) | Nee (default: 1) |
| useInExam | 0 = niet in examen, 1 = wel in examen | Nee (default: 0) |

### Tip: opties in één cel

In de kolom **options** plaats je elk antwoord op een nieuwe regel in dezelfde cel.  
voorbeeld:  
```
Voorrangsweg  
Voorrangskruispunt  
Einde voorrangsweg  
```

## Theorie (theoryChapters)

Dezelfde workflow voor hoofdstukken en lessen:

- **Roady > Theorie: Export naar blad** – haalt `theoryChapters` op
- **Roady > Theorie: Importeer van blad** – schrijft wijzigingen terug

Dit script gebruikt dezelfde collectie-indeling als eerder geconfigureerd.
