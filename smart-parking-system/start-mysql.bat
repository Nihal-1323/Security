@echo off
REM Start MySQL Helper Script
title Start MySQL - Smart Parking System
color 0E

echo.
echo ============================================================
echo              Start MySQL - Smart Parking System
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
echo.
echo Please install XAMPP from: https://www.apachefriends.org/
echo.
pause
exit /b 1

:found_xampp
echo [INFO] Found XAMPP at: %XAMPP_PATH%
echo.

REM Check if MySQL is already running
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [SUCCESS] MySQL is already running!
    echo.
    goto :check_connection
)

echo [INFO] Starting MySQL...
echo.

REM Try to start MySQL
if exist "%XAMPP_PATH%\mysql_start.bat" (
    call "%XAMPP_PATH%\mysql_start.bat"
    timeout /t 3 >nul
) else if exist "%XAMPP_PATH%\mysql\bin\mysqld.exe" (
    start "" "%XAMPP_PATH%\mysql\bin\mysqld.exe" --defaults-file="%XAMPP_PATH%\mysql\bin\my.ini"
    timeout /t 3 >nul
) else (
    echo [WARNING] Could not start MySQL automatically
    echo.
    echo Please start MySQL manually:
    echo 1. Open XAMPP Control Panel
    echo 2. Click "Start" for MySQL
    echo.
    
    if exist "%XAMPP_PATH%\xampp-control.exe" (
        echo [INFO] Opening XAMPP Control Panel...
        start "" "%XAMPP_PATH%\xampp-control.exe"
    )
    
    pause
    exit /b 0
)

:check_connection
echo [INFO] Checking MySQL connection...
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% equ 0 (
    python check-mysql.py
) else (
    echo [INFO] Python not found, skipping connection test
    echo.
    echo Please verify MySQL is running in XAMPP Control Panel
    echo.
)

echo.
echo ============================================================
echo                    Next Steps
echo ============================================================
echo.
echo 1. Verify MySQL is running (green in XAMPP Control Panel)
echo 2. Run the setup script: python setup.py
echo 3. Or manually import database/schema.sql in phpMyAdmin
echo.
echo ============================================================
echo.

pause
