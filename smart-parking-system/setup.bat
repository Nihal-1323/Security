@echo off
REM Smart Parking System - Windows Setup Script
REM Automated installation for Windows with XAMPP/WAMP

title Smart Parking System - Setup
color 0A

echo.
echo ============================================================
echo          Smart Parking System - Automated Setup
echo ============================================================
echo.

REM Check for Python
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Python detected, running Python setup script...
    python setup.py
    pause
    exit /b
)

echo [INFO] Python not found, using batch script...
echo.

REM Detect XAMPP
set XAMPP_PATH=
set WEB_ROOT=
set PROJECT_NAME=smart-parking-system

if exist "C:\xampp" (
    set XAMPP_PATH=C:\xampp
    set WEB_ROOT=C:\xampp\htdocs
    echo [SUCCESS] Found XAMPP at C:\xampp
    goto :found_server
)

if exist "D:\xampp" (
    set XAMPP_PATH=D:\xampp
    set WEB_ROOT=D:\xampp\htdocs
    echo [SUCCESS] Found XAMPP at D:\xampp
    goto :found_server
)

REM Detect WAMP
if exist "C:\wamp64" (
    set WAMP_PATH=C:\wamp64
    set WEB_ROOT=C:\wamp64\www
    echo [SUCCESS] Found WAMP at C:\wamp64
    goto :found_server
)

if exist "C:\wamp" (
    set WAMP_PATH=C:\wamp
    set WEB_ROOT=C:\wamp\www
    echo [SUCCESS] Found WAMP at C:\wamp
    goto :found_server
)

echo [ERROR] Could not find XAMPP or WAMP installation
echo [INFO] Please install XAMPP or WAMP and run this script again
echo.
echo Download XAMPP: https://www.apachefriends.org/
pause
exit /b 1

:found_server
echo.
echo [INFO] Web root: %WEB_ROOT%
echo.

REM Check if destination exists
if exist "%WEB_ROOT%\%PROJECT_NAME%" (
    echo [WARNING] Installation already exists at %WEB_ROOT%\%PROJECT_NAME%
    set /p OVERWRITE="Do you want to overwrite it? (Y/N): "
    if /i not "%OVERWRITE%"=="Y" (
        echo [INFO] Installation cancelled
        pause
        exit /b 0
    )
    echo [INFO] Removing existing installation...
    rmdir /s /q "%WEB_ROOT%\%PROJECT_NAME%"
)

REM Copy files
echo [INFO] Copying project files...
xcopy /E /I /Y /Q "%~dp0*" "%WEB_ROOT%\%PROJECT_NAME%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy files
    echo [INFO] You may need to run this script as Administrator
    pause
    exit /b 1
)

REM Remove setup files from destination
del /q "%WEB_ROOT%\%PROJECT_NAME%\setup.bat" >nul 2>&1
del /q "%WEB_ROOT%\%PROJECT_NAME%\setup.py" >nul 2>&1

echo [SUCCESS] Files copied successfully
echo.

REM Start XAMPP Control Panel if available
if defined XAMPP_PATH (
    if exist "%XAMPP_PATH%\xampp-control.exe" (
        echo [INFO] Starting XAMPP Control Panel...
        start "" "%XAMPP_PATH%\xampp-control.exe"
        echo [SUCCESS] XAMPP Control Panel opened
        echo.
        echo [IMPORTANT] Please start Apache and MySQL from the control panel
        echo.
        pause
    )
)

REM Database setup instructions
echo.
echo ============================================================
echo                    Database Setup Required
echo ============================================================
echo.
echo Please follow these steps to complete the setup:
echo.
echo 1. Make sure Apache and MySQL are running (green in control panel)
echo.
echo 2. Open phpMyAdmin: http://localhost/phpmyadmin
echo.
echo 3. Click "Import" tab
echo.
echo 4. Choose file: %WEB_ROOT%\%PROJECT_NAME%\database\schema.sql
echo.
echo 5. Click "Go" button
echo.
echo 6. Wait for success message
echo.
echo ============================================================
echo.

set /p CONTINUE="Press Enter when database import is complete..."

REM Open test page
echo.
echo [INFO] Opening test connection page...
start http://localhost/%PROJECT_NAME%/test-connection.php

echo.
echo ============================================================
echo                  Installation Complete!
echo ============================================================
echo.
echo Access URLs:
echo   - Test Connection: http://localhost/%PROJECT_NAME%/test-connection.php
echo   - Homepage:        http://localhost/%PROJECT_NAME%/index.html
echo   - Login:           http://localhost/%PROJECT_NAME%/login.html
echo.
echo Default Admin Credentials:
echo   - Username: admin
echo   - Password: Admin@2026
echo   - Role:     Administrator
echo.
echo Installation Location:
echo   - %WEB_ROOT%\%PROJECT_NAME%
echo.
echo Next Steps:
echo   1. Verify all checks pass on the test connection page
echo   2. Access the application and login
echo   3. Change the admin password after first login
echo.
echo ============================================================
echo.

pause
