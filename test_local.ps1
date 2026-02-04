# Roady – Lokaal testen
# Gebruik: .\test_local.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Host "Lokale testomgeving voorbereiden..." -ForegroundColor Cyan

# 1. firebase_hosting map vullen met statische site
if (Test-Path "$root\firebase_hosting") {
    Remove-Item -Recurse -Force "$root\firebase_hosting"
}
New-Item -ItemType Directory -Force "$root\firebase_hosting" | Out-Null
Copy-Item -Path "$root\static_website\*" -Destination "$root\firebase_hosting\" -Recurse -Force

# 2. Flutter web bouwen
Write-Host "  Flutter web bouwen..." -ForegroundColor Yellow
Set-Location $root
& flutter build web --base-href /auth/
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 3. Flutter build kopiëren
New-Item -ItemType Directory -Force "$root\firebase_hosting\auth" | Out-Null
Copy-Item -Path "$root\build\web\*" -Destination "$root\firebase_hosting\auth\" -Recurse -Force

# 4. Lokale Firebase server starten
Write-Host "  Start lokale server..." -ForegroundColor Green
& firebase emulators:start --only hosting
