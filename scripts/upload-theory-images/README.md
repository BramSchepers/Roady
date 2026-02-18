# Upload theory images naar Cloudinary

Uploadt `.webp` afbeeldingen naar **Cloudinary** (gratis) en schrijft de URLs naar **Firestore**.

## Vereisten

- Node.js 18+
- Cloudinary-account (gratis)
- Firebase credentials (voor Firestore)

## Setup

Zie **STAPPENPLAN_CLOUDINARY.md** voor een volledig stappenplan.

Kort:
1. `npm install`
2. `.env` met Firebase + Cloudinary credentials
3. `npm run upload`

## Bestandsstructuur

```
assets/images/theorie/chapter_00/webp/
  chapter_00_lesson_00_01_resultaat.webp  → les 1 (web, volledige resolutie)
  ...
  chapter_00_lesson_00_01_small.webp      → les 1 (mobiel, klein) — optioneel
```

Daarna: **Roady > Theorie: Export naar blad** in Google Sheets om de URLs te zien.
