$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Host "Website bestanden bijwerken (zonder Flutter build)..." -ForegroundColor Cyan

# Kopieer alleen de statische website bestanden naar de hosting map
# Dit overschrijft de HTML/CSS/JS maar laat de 'auth' map (de Flutter app) intact
Copy-Item -Path "$root\static_website\*" -Destination "$root\firebase_hosting\" -Recurse -Force

Write-Host "Klaar! Ververs je browser." -ForegroundColor Green
