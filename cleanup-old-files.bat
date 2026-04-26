@echo off
REM Cleanup Old Files - Keep only smart-parking-system folder
title Cleanup Old Files
color 0E

echo.
echo ============================================================
echo              Cleanup Old Files
echo ============================================================
echo.

echo This will delete old/duplicate files and keep only:
echo • smart-parking-system folder (the working version)
echo • ZIP file
echo • This cleanup script
echo.

set /p CONTINUE="Continue? (Y/N): "
if /i not "%CONTINUE%"=="Y" (
    echo Cleanup cancelled
    exit /b 0
)

echo.
echo Deleting old files...
echo.

REM Delete old HTML files
del /q "about.html" 2>nul
del /q "about.css" 2>nul
del /q "about - Copy.css" 2>nul
del /q "admin_dashboard.html" 2>nul
del /q "admin_dasboard.css" 2>nul
del /q "index.html" 2>nul
del /q "login.html" 2>nul
del /q "login.css" 2>nul
del /q "register.html" 2>nul
del /q "register.css" 2>nul
del /q "start.html" 2>nul
del /q "style.css" 2>nul
del /q "user_dashboard.html" 2>nul
del /q "user_style.css" 2>nul
del /q "parking_system.html" 2>nul

REM Delete old PHP files
del /q "admin_dashboard.php" 2>nul
del /q "book_slot.php" 2>nul
del /q "db_connect.php" 2>nul
del /q "functions.php" 2>nul
del /q "index.php" 2>nul
del /q "login.php" 2>nul
del /q "logout.php" 2>nul
del /q "process_entry.php" 2>nul
del /q "process_exit.php" 2>nul
del /q "register.php" 2>nul
del /q "security_dashboard.php" 2>nul
del /q "submit_feedback.php" 2>nul
del /q "test.php" 2>nul
del /q "user_dashboard.php" 2>nul

REM Delete old SQL files
del /q "database.sql" 2>nul

REM Delete old documentation
del /q "CHECKLIST.txt" 2>nul
del /q "README.md" 2>nul
del /q "SETUP_GUIDE.txt" 2>nul

REM Delete image
del /q "PHOTO-2026-03-14-14-11-26.jpg.jpeg" 2>nul

echo.
echo ============================================================
echo                  Cleanup Complete!
echo ============================================================
echo.
echo Kept:
echo • smart-parking-system\ (working version)
echo • smart-parking-system_*.zip (backup)
echo • ZIP-CREATED.txt (info)
echo.
echo Deleted: Old duplicate files
echo.

pause
