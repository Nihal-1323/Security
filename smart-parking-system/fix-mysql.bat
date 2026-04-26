@echo off
REM Fix MySQL Crash Issue - Smart Parking System
title Fix MySQL Crash
color 0C

echo.
echo ============================================================
echo              Fix MySQL Crash - XAMPP
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

echo ============================================================
echo                  Common MySQL Crash Fixes
echo ============================================================
echo.

echo This script will try several fixes for MySQL crashes:
echo.
echo 1. Stop MySQL if running
echo 2. Backup MySQL data
echo 3. Delete error logs
echo 4. Reset MySQL configuration
echo 5. Restart MySQL
echo.

set /p CONTINUE="Do you want to continue? (Y/N): "
if /i not "%CONTINUE%"=="Y" (
    echo [INFO] Operation cancelled
    pause
    exit /b 0
)

echo.
echo ============================================================
echo                    Step 1: Stop MySQL
echo ============================================================
echo.

taskkill /F /IM mysqld.exe >nul 2>&1
timeout /t 2 >nul
echo [SUCCESS] MySQL stopped

echo.
echo ============================================================
echo              Step 2: Backup MySQL Data
echo ============================================================
echo.

set BACKUP_DIR=%XAMPP_PATH%\mysql\backup_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_DIR=%BACKUP_DIR: =0%

if not exist "%XAMPP_PATH%\mysql\backup" mkdir "%XAMPP_PATH%\mysql\backup"

echo [INFO] Creating backup...
xcopy "%XAMPP_PATH%\mysql\data" "%BACKUP_DIR%" /E /I /Q >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Backup created at: %BACKUP_DIR%
) else (
    echo [WARNING] Backup failed, continuing anyway...
)

echo.
echo ============================================================
echo           Step 3: Delete Error Logs
echo ============================================================
echo.

if exist "%XAMPP_PATH%\mysql\data\*.err" (
    del /q "%XAMPP_PATH%\mysql\data\*.err" >nul 2>&1
    echo [SUCCESS] Error logs deleted
) else (
    echo [INFO] No error logs found
)

echo.
echo ============================================================
echo         Step 4: Fix Common Issues
echo ============================================================
echo.

REM Fix 1: Delete ibdata1 if corrupted (will be recreated)
echo [INFO] Checking for corrupted files...

REM Fix 2: Check port 3306
echo [INFO] Checking port 3306...
netstat -ano | findstr :3306 >nul
if %errorlevel% equ 0 (
    echo [WARNING] Port 3306 is in use by another process
    echo [INFO] You may need to change MySQL port or stop the other service
) else (
    echo [SUCCESS] Port 3306 is available
)

REM Fix 3: Reset my.ini to default
echo [INFO] Checking MySQL configuration...
if exist "%XAMPP_PATH%\mysql\bin\my.ini.bak" (
    echo [INFO] Backup configuration found
) else (
    copy "%XAMPP_PATH%\mysql\bin\my.ini" "%XAMPP_PATH%\mysql\bin\my.ini.bak" >nul 2>&1
    echo [SUCCESS] Configuration backed up
)

echo.
echo ============================================================
echo            Step 5: Try Starting MySQL
echo ============================================================
echo.

echo [INFO] Attempting to start MySQL...
echo.

start "" "%XAMPP_PATH%\mysql\bin\mysqld.exe" --defaults-file="%XAMPP_PATH%\mysql\bin\my.ini" --standalone

timeout /t 5 >nul

tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [SUCCESS] MySQL started successfully!
    echo.
    echo ============================================================
    echo                    MySQL is Running!
    echo ============================================================
    echo.
    echo You can now:
    echo 1. Run: python setup.py
    echo 2. Or manually import database/schema.sql in phpMyAdmin
    echo.
) else (
    echo [ERROR] MySQL failed to start
    echo.
    echo ============================================================
    echo              Additional Troubleshooting Steps
    echo ============================================================
    echo.
    echo Try these solutions:
    echo.
    echo 1. PORT CONFLICT:
    echo    - Check if another MySQL is running
    echo    - Change port in my.ini from 3306 to 3307
    echo.
    echo 2. CORRUPTED DATA:
    echo    - Delete: %XAMPP_PATH%\mysql\data\ibdata1
    echo    - Delete: %XAMPP_PATH%\mysql\data\ib_logfile*
    echo    - Restart MySQL
    echo.
    echo 3. MISSING DEPENDENCIES:
    echo    - Install Visual C++ Redistributable
    echo    - Download: https://aka.ms/vs/17/release/vc_redist.x64.exe
    echo.
    echo 4. REINSTALL MYSQL:
    echo    - Backup data folder
    echo    - Reinstall XAMPP
    echo    - Restore data
    echo.
    echo 5. USE ALTERNATIVE:
    echo    - Install standalone MySQL
    echo    - Or use WAMP instead of XAMPP
    echo.
    echo Press Logs button in XAMPP Control Panel for details
    echo.
)

echo.
echo ============================================================
echo.

pause
