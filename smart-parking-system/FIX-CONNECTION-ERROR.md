# Fix Connection Error - Step by Step Guide

## Problem
Registration page shows "Connection error" when submitting the form.

## Diagnostic Steps

### Step 1: Run PHP Configuration Check
1. Open browser: `http://localhost/smart-parking-system/check-php-config.php`
2. Check if all items show ✓ (green checkmarks)
3. If any show ✗ (red X), note which ones

### Step 2: Run Direct Registration Test
1. Open browser: `http://localhost/smart-parking-system/test-register-direct.php`
2. This will test the database and API directly
3. Click the "Test Registration API" button
4. Check the results

### Step 3: Check Browser Console
1. Open the registration page: `http://localhost/smart-parking-system/register.html`
2. Press F12 to open Developer Tools
3. Go to "Console" tab
4. Try to register a new user
5. Look for error messages in red

### Step 4: Check Apache Error Log
1. Open file: `C:\xampp\apache\logs\error.log`
2. Look for recent PHP errors (check timestamp)
3. Common errors to look for:
   - "Call to undefined function"
   - "Failed to open stream"
   - "Permission denied"

## Common Fixes

### Fix 1: Clear Browser Cache
```
1. Press Ctrl + Shift + Delete
2. Select "Cached images and files"
3. Click "Clear data"
4. Refresh the page (Ctrl + F5)
```

### Fix 2: Check File Paths
The registration form must be at:
- `C:\xampp\htdocs\smart-parking-system\register.html`

The API must be at:
- `C:\xampp\htdocs\smart-parking-system\api\auth.php`

### Fix 3: Restart Apache
```
1. Open XAMPP Control Panel
2. Click "Stop" for Apache
3. Wait 3 seconds
4. Click "Start" for Apache
```

### Fix 4: Check PHP Session Directory
1. Open: `C:\xampp\php\php.ini`
2. Find line: `session.save_path`
3. Make sure directory exists (usually `C:\xampp\tmp`)
4. If not, create the folder
5. Restart Apache

### Fix 5: Enable PHP Error Display
Add this to the top of `api/auth.php` (temporarily):
```php
<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

Then try registration again and check for PHP errors.

## Test Registration Manually

Use this URL to test the API directly:
```
http://localhost/smart-parking-system/test-api.html
```

Click "Test Register" button and check the response.

## Still Not Working?

### Check These:
1. ✓ MySQL is running (green in XAMPP)
2. ✓ Apache is running (green in XAMPP)
3. ✓ Database `smart_parking_db` exists
4. ✓ All 5 tables exist (users, parking_slots, bookings, payments, activity_logs)
5. ✓ File `config/database.php` exists
6. ✓ File `api/auth.php` exists

### Get Detailed Error Info:
1. Open browser console (F12)
2. Go to "Network" tab
3. Try to register
4. Click on the "auth.php" request
5. Check "Response" tab for error message
6. Check "Headers" tab for status code

### Manual Test with cURL:
Open Command Prompt and run:
```cmd
curl -X POST http://localhost/smart-parking-system/api/auth.php?action=register ^
-H "Content-Type: application/json" ^
-d "{\"fullname\":\"Test User\",\"email\":\"test@test.com\",\"phone\":\"1234567890\",\"username\":\"testuser\",\"password\":\"test123\",\"role\":\"user\"}"
```

This will show the exact API response.

## Success Indicators

When working correctly, you should see:
- ✓ All checks pass in `check-php-config.php`
- ✓ Test registration succeeds in `test-register-direct.php`
- ✓ API test shows: `{"success":true,"message":"Registration successful"}`
- ✓ No errors in browser console
- ✓ Registration redirects to login page

## Next Steps After Fix

1. Test registration with a real user
2. Test login with the new user
3. Delete test files (optional):
   - `check-php-config.php`
   - `test-register-direct.php`
   - `test-api.html`
