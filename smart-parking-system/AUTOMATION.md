# Smart Parking System - Automated Setup

This guide explains how to use the automated setup scripts to install the Smart Parking System quickly and easily.

## Available Setup Scripts

We provide three setup scripts for different platforms:

1. **setup.py** - Python script (cross-platform, most features)
2. **setup.bat** - Windows batch script (no Python required)
3. **setup.sh** - Linux/Mac shell script (no Python required)

## Quick Start

### Windows Users

#### Option 1: Using Python (Recommended)
```bash
python setup.py
```

#### Option 2: Using Batch File
```bash
setup.bat
```
Or simply double-click `setup.bat` in File Explorer.

### Linux/Mac Users

#### Option 1: Using Python (Recommended)
```bash
python3 setup.py
```

#### Option 2: Using Shell Script
```bash
chmod +x setup.sh
./setup.sh
```

Or with sudo for automatic service start:
```bash
sudo ./setup.sh
```

## What the Scripts Do

### Automated Tasks

1. **Detect Web Server**
   - Automatically finds XAMPP or WAMP installation
   - Detects web root directory
   - Supports multiple installation paths

2. **Copy Project Files**
   - Copies all project files to web root
   - Creates `smart-parking-system` folder
   - Handles existing installations

3. **Database Setup**
   - Checks MySQL connectivity
   - Creates `smart_parking_db` database
   - Imports schema and default data
   - Creates admin user and parking slots

4. **Service Management**
   - Opens XAMPP/WAMP control panel (Windows)
   - Attempts to start Apache and MySQL (Linux/Mac)
   - Provides manual instructions if needed

5. **Verification**
   - Opens test connection page in browser
   - Displays installation summary
   - Shows access URLs and credentials

## Python Script Features

The Python script (`setup.py`) offers the most features:

### Requirements
- Python 3.6 or higher
- pip (Python package manager)

### Auto-Installation
The script automatically installs required packages:
- `mysql-connector-python` (for database operations)

### Features
- ✅ Cross-platform support (Windows, Linux, macOS)
- ✅ Colored terminal output
- ✅ Automatic MySQL connection testing
- ✅ Database creation and schema import
- ✅ Service detection and management
- ✅ Browser auto-launch
- ✅ Detailed error messages

### Usage
```bash
# Basic usage
python setup.py

# Or on Linux/Mac
python3 setup.py
```

## Batch Script (Windows)

### Features
- ✅ No Python required
- ✅ Detects XAMPP and WAMP
- ✅ Copies files automatically
- ✅ Opens XAMPP Control Panel
- ✅ Provides database import instructions
- ✅ Opens test page in browser

### Usage
```bash
# Run from command prompt
setup.bat

# Or double-click in File Explorer
```

### Requirements
- Windows OS
- XAMPP or WAMP installed
- Administrator rights (may be needed for file copying)

## Shell Script (Linux/Mac)

### Features
- ✅ No Python required
- ✅ Colored terminal output
- ✅ Detects Apache/XAMPP installations
- ✅ Automatic service start (with sudo)
- ✅ Database import
- ✅ Browser auto-launch

### Usage
```bash
# Make executable
chmod +x setup.sh

# Run normally
./setup.sh

# Or with sudo for service management
sudo ./setup.sh
```

### Requirements
- Linux or macOS
- Apache and MySQL installed
- Bash shell

## Supported Web Servers

### Windows
- XAMPP (C:\xampp or D:\xampp)
- WAMP (C:\wamp64, C:\wamp, D:\wamp64, D:\wamp)

### Linux
- Apache (/var/www/html)
- XAMPP (/opt/lampp/htdocs)
- Custom installations

### macOS
- XAMPP (/Applications/XAMPP/htdocs)
- Built-in Apache (~/Sites)

## Troubleshooting

### Script Can't Find Web Server

**Problem:** Script reports "Could not detect web server"

**Solutions:**
1. Install XAMPP or WAMP
2. Manually specify web root in the script
3. Copy files manually to your web root

### Permission Denied Errors

**Windows:**
```bash
# Run as Administrator
# Right-click setup.bat → Run as administrator
```

**Linux/Mac:**
```bash
# Use sudo
sudo ./setup.sh

# Or change permissions
sudo chmod -R 755 /var/www/html/smart-parking-system
```

### MySQL Connection Failed

**Problem:** Cannot connect to MySQL

**Solutions:**
1. Start MySQL service
   - Windows: Use XAMPP/WAMP Control Panel
   - Linux: `sudo systemctl start mysql`
   - Mac: `sudo /opt/lampp/lampp start`

2. Check MySQL credentials in `config/database.php`

3. Verify MySQL is running:
   ```bash
   mysql -u root -p
   ```

### Database Import Failed

**Problem:** Schema import fails

**Manual Solution:**
1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Click "Import" tab
3. Choose file: `database/schema.sql`
4. Click "Go"

**Command Line:**
```bash
# Windows (XAMPP)
C:\xampp\mysql\bin\mysql -u root < database\schema.sql

# Linux/Mac
mysql -u root -p < database/schema.sql
```

### Browser Doesn't Open

**Problem:** Browser doesn't open automatically

**Solution:**
Manually open: `http://localhost/smart-parking-system/test-connection.php`

### Files Not Copied

**Problem:** Files not copied to web root

**Manual Solution:**
```bash
# Windows
xcopy /E /I smart-parking-system C:\xampp\htdocs\smart-parking-system

# Linux/Mac
cp -r smart-parking-system /var/www/html/
```

## Manual Installation

If automated scripts don't work, follow these steps:

1. **Copy Files**
   ```bash
   # Copy entire folder to web root
   # Windows: C:\xampp\htdocs\smart-parking-system
   # Linux: /var/www/html/smart-parking-system
   ```

2. **Start Services**
   - Start Apache
   - Start MySQL

3. **Import Database**
   - Open phpMyAdmin
   - Import `database/schema.sql`

4. **Test**
   - Visit: `http://localhost/smart-parking-system/test-connection.php`

## Post-Installation

After successful installation:

1. **Verify Setup**
   - Visit test connection page
   - Check all tables are created
   - Verify admin user exists

2. **Access Application**
   - Homepage: `http://localhost/smart-parking-system/index.html`
   - Login: `http://localhost/smart-parking-system/login.html`

3. **Login as Admin**
   - Username: `admin`
   - Password: `Admin@2026`
   - Role: Administrator

4. **Change Password**
   - Login to admin dashboard
   - Change default password immediately

## Script Customization

### Modify Web Root Path

**Python (setup.py):**
```python
# Line ~30
self.web_root = Path("C:/your/custom/path")
```

**Batch (setup.bat):**
```batch
REM Line ~40
set WEB_ROOT=C:\your\custom\path
```

**Shell (setup.sh):**
```bash
# Line ~20
WEB_ROOT="/your/custom/path"
```

### Change Project Name

All scripts use `smart-parking-system` as the folder name. To change:

**Python:**
```python
self.project_name = "your-project-name"
```

**Batch:**
```batch
set PROJECT_NAME=your-project-name
```

**Shell:**
```bash
PROJECT_NAME="your-project-name"
```

### Modify Database Credentials

Edit `config/database.php` after installation:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'your_password');
define('DB_NAME', 'smart_parking_db');
```

## Advanced Usage

### Silent Installation (Python)

Create a custom script:
```python
from setup import SmartParkingSetup

setup = SmartParkingSetup()
setup.web_root = Path("C:/xampp/htdocs")
setup.copy_files()
setup.create_database()
```

### Batch Installation (Multiple Servers)

Use the scripts in a loop for multiple servers:
```bash
for server in server1 server2 server3; do
    ssh $server 'bash -s' < setup.sh
done
```

## Support

### Getting Help

1. Check `SETUP.md` for detailed manual instructions
2. Run `test-connection.php` to diagnose issues
3. Check Apache/MySQL error logs
4. Review browser console for JavaScript errors

### Common Issues

- **Port conflicts:** Change Apache port in httpd.conf
- **Firewall:** Allow Apache and MySQL through firewall
- **Permissions:** Ensure web root is writable
- **PHP version:** Requires PHP 7.4 or higher

## Version

Automation Scripts Version 1.0.0

## License

© 2026 Smart Parking Management System. All Rights Reserved.

---

**Happy Installing! 🚀**
