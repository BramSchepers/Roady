# Roady

Rijbewijs theorie quiz app – oefen voor je theorie-examen.

## Opzet

- **Startscherm**: korte intro, knop “Start oefenen”.
- **Quiz**: één vraag per scherm, meerkeuze, directe feedback (goed/fout), voortgang en punten/streak.
- **Resultaat**: score, “Opnieuw” en “Terug naar start”.

Vragen staan in `assets/questions.json`.

## Vereisten

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stabiele channel)
- Voor **iPhone**: Mac met Xcode

## Project genereren (eerste keer)

Als de mappen `android/` of `ios/` nog niet compleet zijn, maak het project af met:

```bash
cd c:\Users\brams\Desktop\Roady
flutter create . --project-name roady
```

Daarna:

```bash
flutter pub get
```

## Lokaal testen

### Windows (zonder iPhone)

- **Chrome**  
  ```bash
  flutter run -d chrome
  ```
- **Windows desktop**  
  ```bash
  flutter run -d windows
  ```
- **Android-emulator** (als Android Studio + emulator geïnstalleerd zijn)  
  ```bash
  flutter run
  ```
  of  
  ```bash
  flutter run -d <device-id>
  ```
  (`flutter devices` toont beschikbare apparaten.)

### Op een echte iPhone

Alleen mogelijk vanaf een **Mac met Xcode**:

1. Xcode installeren, iPhone via USB aansluiten en “Deze computer vertrouwen” bevestigen.
2. In Xcode een (gratis) Apple Developer-account toevoegen.
3. In de projectmap:
   ```bash
   cd /pad/naar/Roady
   flutter run -d <id-van-je-iphone>
   ```
   Of in Xcode `ios/Runner.xcworkspace` openen, je iPhone als doel kiezen, signing instellen en daarna vanuit de terminal `flutter run` doen.

Zonder Mac: bouw de **webversie** (`flutter run -d chrome`) en open die later op je telefoon via een gehoste URL, of gebruik een cloud-Mac (bijv. Codemagic) voor een iOS-build.

## Controle van de installatie

```bash
flutter doctor
```

## Website

De companion-website staat in **`website/`** (HTML, CSS, JavaScript), naast de Flutter-app. Zelfde repo, zelfde backend (Supabase) bedoeld voor app en site.

**Lokaal openen:**

- `index.html` direct in de browser, of
- bijvoorbeeld `npx serve website` (vanuit de projectroot) en dan de getoonde URL openen.

**Supabase:** Gebruik hetzelfde Supabase-project voor de Flutter-app en de website. Kopieer `website/js/config.js.example` naar `website/js/config.js`, vul `SUPABASE_URL` en `SUPABASE_ANON_KEY` in. `config.js` staat in `.gitignore`; commit geen keys.

## Licentie

Privé / educatief gebruik.
