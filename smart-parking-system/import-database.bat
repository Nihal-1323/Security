@echo off
REM Import Database - Smart Parking System
title Import Database
color 0A

echo.
echo ============================================================
echo          Import Database - Smart Parking System
echo ============================================================
echo.

REM Detect XAMPP
set XAMPP_PATH=

if exist "C:\xampp" (
    set XAMPP_PATH=C:\xampp
    goto :found_xampp
)

if exist "D:\xampp" (
    set XAMPP_PATH=D:\xampp
    goto :found_xampp
)

echo [ERROR] Could not find XAMPP installation
pause
exit /b 1

:found_xampp
echo [INFO] Found XAMPP at: %XAMPP_PATH%
echo.

REM Check if MySQL is running
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="1" (
    echo [ERROR] MySQL is not running!
    echo.
    echo Please start MySQL in XAMPP Control Panel first.
    echo.
    pause
    exit /b 1
)

echo [SUCCESS] MySQL is running
echo.

REM Check if schema file exists
if not exist "database\schema.sql" (
    echo [ERROR] Database schema file not found!
    echo Expected: database\schema.sql
    echo.
    pause
    exit /b 1
)

echo [INFO] Found database schema file
echo.

echo ============================================================
echo                  Importing Database
echo ============================================================
echo.

echo This will:
echo 1. Create database 'smart_parking_db'
echo 2. Create 5 tables
echo 3. Add default admin user
echo 4. Add 14 parking slots
echo.

set /p CONTINUE="Continue? (Y/N): "
if /i not "%CONTINUE%"=="Y" (
    echo [INFO] Import cancelled
    pause
    exit /b 0
)

echo.
echo [INFO] Importing database...
echo.

REM Import database
"%XAMPP_PATH%\mysql\bin\mysql.exe" -u root < "database\schema.sql" 2>nul

if %errorlevel% equ 0 (
    echo [SUCCESS] Database imported successfully!
    echo.
    
    REM Verify tables
    echo [INFO] Verifying tables...
    echo.
    
    "%XAMPP_PATH%\mysql\bin\mysql.exe" -u root -e "USE smart_parking_db; SHOW TABLES;" 2>nul
    
    echo.
    echo ============================================================
    echo                  Import Complete!
    echo ============================================================
    echo.
    echo Database: smart_parking_db
    echo Tables: 5 (users, parking_slots, bookings, payments, activity_logs)
    echo Admin User: admin / Admin@2026
    echo Parking Slots: 14 (A1-D2)
    echo.
    echo ============================================================
    echo                    Next Steps
    echo ============================================================
    echo.
    echo 1. Visit: http://localhost/smart-parking-system/test-connection.php
    echo    (Should show all green checks now)
    echo.
    echo 2. Go to: http://localhost/smart-parking-system/index.html
    echo.
    echo 3. Login with:
    echo    Username: admin
    echo    Password: Admin@2026
    echo    Role: Administrator
    echo.
    echo ============================================================
    echo.
    
) else (
    echo [ERROR] Database import failed!
    echo.
    echo Possible reasons:
    echo 1. MySQL is not running
    echo 2. Permission denied
    echo 3. Database already exists with errors
    echo.
    echo Try this:
    echo 1. Open phpMyAdmin: http://localhost/phpmyadmin
    echo 2. Delete database 'smart_parking_db' if it exists
    echo 3. Run this script again
    echo.
)

pause
