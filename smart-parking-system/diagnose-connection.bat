@echo off
echo ============================================================
echo   DIAGNOSE CONNECTION ERROR
echo ============================================================
echo.
echo This will open diagnostic pages in your browser.
echo.
echo Opening diagnostic tools...
echo.

REM Open PHP config check
start http://localhost/smart-parking-system/check-php-config.php

timeout /t 2 /nobreak >nul

REM Open registration test
start http://localhost/smart-parking-system/test-register-direct.php

timeout /t 2 /nobreak >nul

REM Open API test
start http://localhost/smart-parking-system/test-api.html

echo.
echo ============================================================
echo   DIAGNOSTIC PAGES OPENED
echo ============================================================
echo.
echo Three browser tabs should have opened:
echo.
echo 1. PHP Configuration Check
echo    - Check if all items show green checkmarks
echo.
echo 2. Direct Registration Test
echo    - Click "Test Registration API" button
echo    - Check the result
echo.
echo 3. API Test Page
echo    - Click "Test Register" button
echo    - Check the response
echo.
echo ============================================================
echo.
echo If all tests pass but registration still fails:
echo 1. Press F12 in the registration page
echo 2. Go to Console tab
echo 3. Try to register
echo 4. Check for error messages
echo.
echo For detailed guide, see: DIAGNOSE-CONNECTION-ERROR.txt
echo.
pause
