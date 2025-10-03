# GeoRemind Quick Start Script
# Run this script to start the GeoRemind application

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   GeoRemind - Quick Start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Add Flutter to PATH for this session
$env:Path += ";$env:USERPROFILE\flutter-sdk\flutter\bin"

# Check if Flutter is available
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterVersion = flutter --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Flutter is installed" -ForegroundColor Green
} else {
    Write-Host "✗ Flutter not found. Please install Flutter first." -ForegroundColor Red
    Write-Host "  See SETUP.md for instructions" -ForegroundColor Yellow
    exit 1
}

# Check Developer Mode (Windows)
Write-Host ""
Write-Host "Checking Windows Developer Mode..." -ForegroundColor Yellow
Write-Host "If the app fails to build, enable Developer Mode:" -ForegroundColor Yellow
Write-Host "  Run: start ms-settings:developers" -ForegroundColor Cyan
Write-Host ""

# Get dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to get dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Check available devices
Write-Host "Checking available devices..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Select platform to run:" -ForegroundColor Cyan
Write-Host "  1. Windows Desktop" -ForegroundColor White
Write-Host "  2. Android (device/emulator)" -ForegroundColor White
Write-Host "  3. Exit" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Launching GeoRemind on Windows..." -ForegroundColor Green
        Write-Host ""
        Write-Host "Tips:" -ForegroundColor Yellow
        Write-Host "  - Press 'r' to hot reload" -ForegroundColor Cyan
        Write-Host "  - Press 'R' to hot restart" -ForegroundColor Cyan
        Write-Host "  - Press 'q' to quit" -ForegroundColor Cyan
        Write-Host ""
        flutter run -d windows
    }
    "2" {
        Write-Host ""
        Write-Host "Launching GeoRemind on Android..." -ForegroundColor Green
        Write-Host ""
        flutter run
    }
    "3" {
        Write-Host ""
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host ""
        Write-Host "Invalid choice. Exiting..." -ForegroundColor Red
        exit 1
    }
}
