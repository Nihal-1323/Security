@echo off
REM Create ZIP Archive - Smart Parking System
title Create ZIP Archive
color 0B

echo.
echo ============================================================
echo        Smart Parking System - Create ZIP Archive
echo ============================================================
echo.

REM Check for Python
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Using Python to create ZIP...
    python create-zip.py
    pause
    exit /b
)

echo [INFO] Python not found, using PowerShell...
echo.

REM Use PowerShell to create ZIP
powershell -Command "& { ^
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'; ^
    $zipName = 'smart-parking-system_' + $timestamp + '.zip'; ^
    $source = Get-Location; ^
    $destination = Join-Path (Split-Path $source) $zipName; ^
    Write-Host 'Creating ZIP archive...' -ForegroundColor Cyan; ^
    Compress-Archive -Path $source\* -DestinationPath $destination -Force; ^
    Write-Host ''; ^
    Write-Host 'ZIP Created Successfully!' -ForegroundColor Green; ^
    Write-Host 'Location:' $destination; ^
    Write-Host ''; ^
}"

echo.
echo ============================================================
echo                    ZIP Created!
echo ============================================================
echo.
echo The ZIP file has been created in the parent folder.
echo You can now share or backup this file.
echo.

pause
