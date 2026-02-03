# Build static site + Flutter web for Firebase Hosting
# Landing at / and Flutter app at /auth so "Start gratis" goes to login.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

Write-Host "Building Flutter web (base href /auth/)..." -ForegroundColor Cyan
flutter build web --base-href /auth/

$hosting = Join-Path $root "build\hosting"
$auth = Join-Path $hosting "auth"

Write-Host "Preparing build/hosting..." -ForegroundColor Cyan
if (Test-Path $hosting) { Remove-Item $hosting -Recurse -Force }
New-Item -ItemType Directory -Path $hosting -Force | Out-Null

Write-Host "Copying static website to build/hosting..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $root "static_website\*") -Destination $hosting -Recurse -Force

Write-Host "Copying Flutter web build to build/hosting/auth..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $auth -Force | Out-Null
Copy-Item -Path (Join-Path $root "build\web\*") -Destination $auth -Recurse -Force

Write-Host "Done. Deploy with: firebase deploy" -ForegroundColor Green
