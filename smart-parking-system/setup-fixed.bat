@echo off
echo ============================================================
echo   Smart Parking System - Setup (Fixed Version)
echo ============================================================
echo.
echo This script will:
echo 1. Stop Apache (if running)
echo 2. Import database
echo 3. Start Apache again
echo.
echo ============================================================
echo.

REM Check if running from correct location
if not exist "database\schema.sql" (
    echo ERROR: Please run this script from the smart-parking-system folder!
    echo Current location: %CD%
    echo.
    pause
    exit /b 1
)

echo Step 1: Stopping Apache...
echo.
net stop Apache2.4 2>nul
if %errorlevel% equ 0 (
    echo Apache stopped successfully.
    timeout /t 2 /nobreak >nul
) else (
    echo Apache was not running or could not be stopped.
    echo Continuing anyway...
)
echo.

echo Step 2: Importing database...
echo.

REM Try to find MySQL
set MYSQL_PATH=
if exist "C:\xampp\mysql\bin\mysql.exe" set MYSQL_PATH=C:\xampp\mysql\bin\mysql.exe
if exist "C:\wamp64\bin\mysql\mysql8.0.27\bin\mysql.exe" set MYSQL_PATH=C:\wamp64\bin\mysql\mysql8.0.27\bin\mysql.exe
if exist "C:\wamp\bin\mysql\mysql8.0.27\bin\mysql.exe" set MYSQL_PATH=C:\wamp\bin\mysql\mysql8.0.27\bin\mysql.exe

if "%MYSQL_PATH%"=="" (
    echo ERROR: MySQL not found!
    echo Please make sure XAMPP or WAMP is installed.
    echo.
    pause
    exit /b 1
)

echo Found MySQL at: %MYSQL_PATH%
echo.

REM Create database and import schema
echo Creating database and importing schema...
"%MYSQL_PATH%" -u root -e "CREATE DATABASE IF NOT EXISTS smart_parking_db;"
"%MYSQL_PATH%" -u root smart_parking_db < database\schema.sql

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo   Database imported successfully!
    echo ============================================================
    echo.
) else (
    echo.
    echo ============================================================
    echo   ERROR: Database import failed!
    echo ============================================================
    echo.
    echo Please check:
    echo 1. MySQL is running in XAMPP Control Panel
    echo 2. MySQL password is empty (default)
    echo.
    pause
    exit /b 1
)

echo Step 3: Starting Apache...
echo.
net start Apache2.4 2>nul
if %errorlevel% equ 0 (
    echo Apache started successfully.
) else (
    echo Could not start Apache automatically.
    echo Please start it manually from XAMPP Control Panel.
)
echo.

echo ============================================================
echo   Setup completed successfully!
echo ============================================================
echo.
echo Database: smart_parking_db
echo Tables: 5 (users, parking_slots, bookings, payments, activity_logs)
echo Parking Slots: 14 (A1-D3)
echo Admin User: admin / Admin@2026
echo.
echo Next steps:
echo 1. Make sure Apache is GREEN in XAMPP Control Panel
echo 2. Make sure MySQL is GREEN in XAMPP Control Panel
echo 3. Open browser: http://localhost/smart-parking-system/
echo.
echo To verify: http://localhost/smart-parking-system/test-connection.php
echo.
pause
