# Roady – Firebase deploy (statische site + Flutter web op /auth)
# Gebruik: .\deploy.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Host "Deploy voorbereiden..." -ForegroundColor Cyan

# 1. firebase_hosting (opnieuw) aanmaken en vullen met statische site
if (Test-Path "$root\firebase_hosting") {
    Remove-Item -Recurse -Force "$root\firebase_hosting"
}
New-Item -ItemType Directory -Force "$root\firebase_hosting" | Out-Null
Copy-Item -Path "$root\static_website\*" -Destination "$root\firebase_hosting\" -Recurse -Force
Write-Host "  Statische site gekopieerd naar firebase_hosting\" -ForegroundColor Green

# 2. Flutter web bouwen voor /auth
Write-Host "  Flutter web bouwen (base-href /auth/)..." -ForegroundColor Yellow
& flutter build web --base-href /auth/
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 3. Flutter build in firebase_hosting/auth/ zetten
New-Item -ItemType Directory -Force "$root\firebase_hosting\auth" | Out-Null
Copy-Item -Path "$root\build\web\*" -Destination "$root\firebase_hosting\auth\" -Recurse -Force
Write-Host "  Flutter web gekopieerd naar firebase_hosting\auth\" -ForegroundColor Green

# 4. Deploy naar Firebase
Write-Host "  Deployen naar Firebase..." -ForegroundColor Yellow
Set-Location $root
& firebase deploy
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Deploy klaar. Hosting URL: https://goroady-22332.web.app" -ForegroundColor Green
Write-Host "Flutter app: https://goroady-22332.web.app/auth" -ForegroundColor Green
