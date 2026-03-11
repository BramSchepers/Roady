# Upload quiz images

Upload afbeeldingen voor oefenvragen naar Cloudinary en zet het veld `imageUrl` in Firestore collectie `quizQuestions`.

## Gebruik

1. **Afbeeldingen klaarzetten**  
   Plaats bestanden in `assets/images/quiz/`. Bestandsnaam = Firestore document-id van de vraag, bv.:
   - `ts_1.webp` → update `quizQuestions/ts_1`
   - `gen_2.png` → update `quizQuestions/gen_2`  
   Ondersteund: `.webp`, `.png`, `.jpg`, `.jpeg`.

2. **Environment**  
   Zet een `.env` in deze map (of gebruik dezelfde als bij `upload-theory-images`):
   - `GOOGLE_APPLICATION_CREDENTIALS` = pad naar service account JSON, **of**
   - `PROJECT_ID`, `CLIENT_EMAIL`, `PRIVATE_KEY` (Firebase)
   - `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`

3. **Uitvoeren**
   ```bash
   cd scripts/upload-quiz-images
   npm install
   npm run upload
   ```

Bestanden waarvan geen document met die id in `quizQuestions` bestaat, worden overgeslagen (met een waarschuwing).
