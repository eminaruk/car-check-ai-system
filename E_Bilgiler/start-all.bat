@echo off
chcp 65001 >nul
title CarCheck AI - Starter
echo ============================================
echo    CarCheck AI - Tum Servisleri Baslatma
echo ============================================
echo.

set PROJECT_DIR=C:\Users\Emre\Desktop\My programs\Unity\Work\car-check-ai-system

echo [1/4] Firebase Emulator baslatiliyor...
start "Firebase Emulator" cmd /k "cd /d "%PROJECT_DIR%\firebase" && npm run emulator"

echo Emulator icin 15 saniye bekleniyor...
ping localhost -n 16 >nul

echo [2/4] Backend baslatiliyor...
start "Backend - FastAPI" cmd /k "cd /d "%PROJECT_DIR%\backend" && uvicorn main:app --reload --host 0.0.0.0 --port 8000"

echo Backend icin 8 saniye bekleniyor...
ping localhost -n 9 >nul

echo [3/4] Test verileri yukleniyor (seed)...
cd /d "%PROJECT_DIR%\firebase"
call npm run seed

echo.
echo Seed tamamlandi, 3 saniye bekleniyor...
ping localhost -n 4 >nul

echo [4/4] Flutter baslatiliyor...
start "Flutter - Chrome" cmd /k "cd /d "%PROJECT_DIR%\frontend" && flutter run -d chrome --web-renderer html"

echo.
echo ============================================
echo    Tum servisler baslatildi!
echo ============================================
echo.
echo Acik pencereler:
echo   - Firebase Emulator (localhost:8080)
echo   - Backend API (localhost:8000)
echo   - Flutter (Chrome)
echo.
echo Emulator UI: http://127.0.0.1:4000
echo.
pause
