@echo off
REM Diagnose MySQL Issues
title MySQL Diagnostics
color 0B

echo.
echo ============================================================
echo              MySQL Crash Diagnostics
echo ============================================================
echo.

echo Running diagnostics...
echo.

REM Check 1: Port 3306
echo [CHECK 1] Port 3306 Status
echo ----------------------------------------
netstat -ano | findstr :3306
if %errorlevel% equ 0 (
    echo [WARNING] Port 3306 is in use!
    echo.
    echo Finding process using port 3306...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3306') do (
        echo Process ID: %%a
        tasklist /FI "PID eq %%a"
    )
) else (
    echo [OK] Port 3306 is available
)
echo.

REM Check 2: MySQL Process
echo [CHECK 2] MySQL Process Status
echo ----------------------------------------
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] MySQL is running
    tasklist /FI "IMAGENAME eq mysqld.exe"
) else (
    echo [WARNING] MySQL is not running
)
echo.

REM Check 3: XAMPP Installation
echo [CHECK 3] XAMPP Installation
echo ----------------------------------------
if exist "C:\xampp" (
    echo [OK] XAMPP found at C:\xampp
    set XAMPP_PATH=C:\xampp
) else if exist "D:\xampp" (
    echo [OK] XAMPP found at D:\xampp
    set XAMPP_PATH=D:\xampp
) else (
    echo [ERROR] XAMPP not found
    set XAMPP_PATH=
)
echo.

if defined XAMPP_PATH (
    REM Check 4: MySQL Files
    echo [CHECK 4] MySQL Files
    echo ----------------------------------------
    if exist "%XAMPP_PATH%\mysql\bin\mysqld.exe" (
        echo [OK] mysqld.exe found
    ) else (
        echo [ERROR] mysqld.exe not found
    )
    
    if exist "%XAMPP_PATH%\mysql\bin\my.ini" (
        echo [OK] my.ini found
    ) else (
        echo [ERROR] my.ini not found
    )
    
    if exist "%XAMPP_PATH%\mysql\data" (
        echo [OK] data folder found
    ) else (
        echo [ERROR] data folder not found
    )
    echo.
    
    REM Check 5: Error Logs
    echo [CHECK 5] Recent Error Logs
    echo ----------------------------------------
    if exist "%XAMPP_PATH%\mysql\data\*.err" (
        echo [WARNING] Error logs found:
        dir /b "%XAMPP_PATH%\mysql\data\*.err"
        echo.
        echo Last 10 lines of latest error log:
        for /f %%i in ('dir /b /o-d "%XAMPP_PATH%\mysql\data\*.err" 2^>nul') do (
            powershell -Command "Get-Content '%XAMPP_PATH%\mysql\data\%%i' -Tail 10"
            goto :done_logs
        )
        :done_logs
    ) else (
        echo [OK] No error logs found
    )
    echo.
    
    REM Check 6: Disk Space
    echo [CHECK 6] Disk Space
    echo ----------------------------------------
    for /f "tokens=3" %%a in ('dir /-c %XAMPP_PATH% ^| findstr "bytes free"') do (
        echo Free space: %%a bytes
    )
    echo.
)

REM Check 7: Windows Services
echo [CHECK 7] MySQL Windows Services
echo ----------------------------------------
sc query | findstr /i "mysql" >nul
if %errorlevel% equ 0 (
    echo [INFO] MySQL services found:
    sc query | findstr /i "mysql"
    echo.
    echo [WARNING] Multiple MySQL services may cause conflicts
) else (
    echo [OK] No MySQL Windows services found
)
echo.

REM Check 8: Visual C++ Redistributable
echo [CHECK 8] Visual C++ Redistributable
echo ----------------------------------------
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Visual C++ Redistributable installed
) else (
    echo [WARNING] Visual C++ Redistributable may be missing
    echo Download: https://aka.ms/vs/17/release/vc_redist.x64.exe
)
echo.

echo ============================================================
echo                    Diagnostic Summary
echo ============================================================
echo.
echo Common Issues Found:
echo.

REM Summary
netstat -ano | findstr :3306 >nul
if %errorlevel% equ 0 (
    echo [!] Port 3306 is blocked - MOST COMMON ISSUE
    echo     Solution: Stop other MySQL service or change port
    echo.
)

tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="1" (
    echo [!] MySQL is not running
    echo     Solution: Try starting MySQL in XAMPP Control Panel
    echo.
)

if exist "%XAMPP_PATH%\mysql\data\*.err" (
    echo [!] Error logs present
    echo     Solution: Check logs for specific errors
    echo.
)

echo ============================================================
echo                    Recommended Actions
echo ============================================================
echo.
echo 1. If port 3306 is blocked:
echo    - Run: fix-mysql.bat
echo    - Or manually stop conflicting service
echo.
echo 2. If MySQL won't start:
echo    - Check error logs in XAMPP Control Panel
echo    - Try: fix-mysql.bat
echo.
echo 3. If files are corrupted:
echo    - Backup data folder
echo    - Delete ibdata1 and ib_logfile*
echo    - Restart MySQL
echo.
echo 4. If nothing works:
echo    - Read: MYSQL-CRASH-FIX.md
echo    - Consider reinstalling XAMPP
echo.
echo ============================================================
echo.

pause
