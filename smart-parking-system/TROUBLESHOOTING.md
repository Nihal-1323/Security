# Troubleshooting Guide

Common issues and solutions for Smart Parking System installation.

## MySQL Connection Issues

### Error: "Access denied for user 'root'@'localhost'"

**Problem:** MySQL is running but requires a password.

**Solution:**

1. **Find your MySQL password:**
   - Check XAMPP Control Panel → MySQL → Config → my.ini
   - Or try common passwords: empty, root, password

2. **Update database configuration:**
   ```php
   // Edit: config/database.php
   define('DB_PASS', 'your_mysql_password');
   ```

3. **Run setup again:**
   ```bash
   python setup.py
   ```

### Error: "Can't connect to MySQL server"

**Problem:** MySQL is not running.

**Solution:**

**Windows (XAMPP):**
```bash
# Option 1: Use helper script
start-mysql.bat

# Option 2: Manual
1. Open XAMPP Control Panel
2. Click "Start" for MySQL
3. Wait for green indicator
4. Run: python setup.py
```

**Linux:**
```bash
sudo systemctl start mysql
# or
sudo service mysql start
```

**Mac:**
```bash
sudo /opt/lampp/lampp startmysql
```

### Error: "MySQL is not accessible"

**Problem:** MySQL service is not installed or not in PATH.

**Solution:**

1. **Verify XAMPP/WAMP is installed**
2. **Check MySQL is in the installation:**
   - XAMPP: `C:\xampp\mysql\bin\mysql.exe`
   - WAMP: `C:\wamp64\bin\mysql\mysql8.x.x\bin\mysql.exe`

3. **Start MySQL from control panel**

## Database Import Issues

### Error: "Database import failed"

**Problem:** Automatic database creation failed.

**Manual Solution:**

1. **Open phpMyAdmin:**
   ```
   http://localhost/phpmyadmin
   ```

2. **Create database:**
   - Click "New" in left sidebar
   - Database name: `smart_parking_db`
   - Collation: `utf8mb4_general_ci`
   - Click "Create"

3. **Import schema:**
   - Select `smart_parking_db`
   - Click "Import" tab
   - Choose file: `database/schema.sql`
   - Click "Go"
   - Wait for success message

**Command Line Alternative:**
```bash
# Windows (XAMPP)
C:\xampp\mysql\bin\mysql -u root < database\schema.sql

# Linux/Mac
mysql -u root -p < database/schema.sql
```

### Error: "Table already exists"

**Problem:** Database was partially created.

**Solution:**

1. **Drop existing database:**
   ```sql
   DROP DATABASE IF EXISTS smart_parking_db;
   ```

2. **Import schema again:**
   ```bash
   python setup.py
   ```

## File Copy Issues

### Error: "Permission denied"

**Problem:** Insufficient permissions to copy files.

**Solution:**

**Windows:**
```bash
# Run as Administrator
1. Right-click Command Prompt
2. Select "Run as administrator"
3. Navigate to folder
4. Run: python setup.py
```

**Linux/Mac:**
```bash
# Use sudo
sudo python3 setup.py

# Or change permissions
sudo chmod -R 755 /var/www/html/smart-parking-system
```

### Error: "Destination already exists"

**Problem:** Previous installation exists.

**Solution:**

The script will ask if you want to overwrite. Choose:
- `y` - Remove old installation and continue
- `n` - Cancel installation

**Manual removal:**
```bash
# Windows
rmdir /s C:\xampp\htdocs\smart-parking-system

# Linux/Mac
rm -rf /var/www/html/smart-parking-system
```

## Web Server Issues

### Error: "Could not detect web server"

**Problem:** XAMPP/WAMP not installed or in non-standard location.

**Solution:**

1. **Install XAMPP:**
   - Download: https://www.apachefriends.org/
   - Install to default location

2. **Or specify custom path:**
   Edit `setup.py` line ~30:
   ```python
   self.web_root = Path("C:/your/custom/path")
   ```

3. **Or copy manually:**
   ```bash
   # Copy entire folder to web root
   xcopy /E /I smart-parking-system C:\xampp\htdocs\smart-parking-system
   ```

### Error: "Apache is not running"

**Problem:** Apache web server is not started.

**Solution:**

1. **Start Apache:**
   - Open XAMPP/WAMP Control Panel
   - Click "Start" for Apache
   - Wait for green indicator

2. **Check port conflicts:**
   - Default port: 80
   - If blocked, change in httpd.conf
   - Or stop conflicting service (Skype, IIS)

3. **Test Apache:**
   ```
   http://localhost/
   ```

## Python Issues

### Error: "Python is not recognized"

**Problem:** Python not installed or not in PATH.

**Solution:**

1. **Install Python:**
   - Download: https://www.python.org/downloads/
   - Check "Add Python to PATH" during installation

2. **Or use batch/shell script:**
   ```bash
   # Windows
   setup.bat
   
   # Linux/Mac
   ./setup.sh
   ```

### Error: "pip install failed"

**Problem:** pip cannot install packages.

**Solution:**

1. **Update pip:**
   ```bash
   python -m pip install --upgrade pip
   ```

2. **Install manually:**
   ```bash
   pip install mysql-connector-python
   ```

3. **Check internet connection**

## Browser Issues

### Error: "Browser doesn't open"

**Problem:** Automatic browser launch failed.

**Solution:**

Manually open these URLs:

- **Test Connection:**
  ```
  http://localhost/smart-parking-system/test-connection.php
  ```

- **Homepage:**
  ```
  http://localhost/smart-parking-system/index.html
  ```

- **Login:**
  ```
  http://localhost/smart-parking-system/login.html
  ```

### Error: "Page not found (404)"

**Problem:** Files not in correct location or Apache not running.

**Solution:**

1. **Verify file location:**
   - Should be in: `C:\xampp\htdocs\smart-parking-system\`
   - Check folder exists and contains files

2. **Check Apache is running**

3. **Try different URL:**
   ```
   http://localhost/smart-parking-system/
   http://127.0.0.1/smart-parking-system/
   ```

## Application Issues

### Error: "Login failed"

**Problem:** Database not set up or credentials incorrect.

**Solution:**

1. **Verify database:**
   ```
   http://localhost/smart-parking-system/test-connection.php
   ```

2. **Check all green checkmarks**

3. **Use correct credentials:**
   - Username: `admin`
   - Password: `Admin@2026`
   - Role: Administrator

4. **Reset admin password:**
   ```sql
   UPDATE users 
   SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' 
   WHERE username = 'admin';
   ```

### Error: "Parking slots not loading"

**Problem:** Database connection issue or API error.

**Solution:**

1. **Check browser console (F12)**

2. **Verify database connection:**
   - Visit test-connection.php
   - Check all tables exist

3. **Check API endpoints:**
   ```
   http://localhost/smart-parking-system/api/slots.php?action=getAll
   ```

4. **Review PHP error logs:**
   - XAMPP: `C:\xampp\apache\logs\error.log`

## Diagnostic Tools

### Check MySQL Status

```bash
# Run diagnostic script
python check-mysql.py
```

### Test Database Connection

```
http://localhost/smart-parking-system/test-connection.php
```

### Check Apache Status

```
http://localhost/
```

### View PHP Info

Create `info.php`:
```php
<?php phpinfo(); ?>
```

Visit: `http://localhost/info.php`

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Access denied" | MySQL password | Update config/database.php |
| "Can't connect" | MySQL not running | Start MySQL |
| "Permission denied" | Insufficient rights | Run as admin/sudo |
| "404 Not Found" | Wrong path | Check file location |
| "500 Internal Error" | PHP error | Check error logs |
| "Database not found" | Not imported | Import schema.sql |

## Getting More Help

### 1. Run Diagnostics
```bash
python check-mysql.py
```

### 2. Check Test Page
```
http://localhost/smart-parking-system/test-connection.php
```

### 3. Review Logs
- Apache: `C:\xampp\apache\logs\error.log`
- MySQL: `C:\xampp\mysql\data\mysql_error.log`
- Browser Console: Press F12

### 4. Verify Requirements
- [ ] XAMPP/WAMP installed
- [ ] Apache running (green)
- [ ] MySQL running (green)
- [ ] Files in web root
- [ ] Database imported

## Quick Fixes

### Reset Everything

```bash
# 1. Stop services
# 2. Delete installation
rmdir /s C:\xampp\htdocs\smart-parking-system

# 3. Drop database
mysql -u root -e "DROP DATABASE smart_parking_db"

# 4. Start fresh
python setup.py
```

### Manual Installation

If automation fails, install manually:

1. Copy files to `C:\xampp\htdocs\smart-parking-system\`
2. Start Apache and MySQL
3. Import `database/schema.sql` in phpMyAdmin
4. Visit `http://localhost/smart-parking-system/`

## Still Having Issues?

1. Read `SETUP.md` for detailed manual instructions
2. Check `AUTOMATION.md` for script documentation
3. Review error logs
4. Verify all requirements are met

---

**Most Common Issue:** MySQL not running. Solution: Start MySQL in XAMPP Control Panel!
