# Installation Guide

## Automated Installation (Recommended)

### Windows
```bash
# Option 1: Batch file (easiest)
setup.bat

# Option 2: Python script
python setup.py
```

### Linux/Mac
```bash
# Option 1: Shell script
chmod +x setup.sh
./setup.sh

# Option 2: Python script
python3 setup.py
```

## What Gets Installed

- ✅ All project files copied to web root
- ✅ Database created and configured
- ✅ Admin user and parking slots added
- ✅ Test page opened in browser

## Requirements

- XAMPP or WAMP installed
- Apache and MySQL running
- Python 3.6+ (optional)

## After Installation

1. Visit: `http://localhost/smart-parking-system/test-connection.php`
2. Verify all checks pass
3. Login with: `admin` / `Admin@2026`
4. Change password immediately

## Need Help?

- See `QUICKSTART.txt` for quick reference
- See `AUTOMATION.md` for detailed automation guide
- See `SETUP.md` for manual installation steps

## Troubleshooting

**Script can't find web server:**
- Install XAMPP from https://www.apachefriends.org/

**Database connection failed:**
- Start MySQL in XAMPP/WAMP Control Panel
- Import `database/schema.sql` manually

**Permission denied:**
- Windows: Run as Administrator
- Linux/Mac: Use `sudo ./setup.sh`

---

**Quick Start:** Just run `setup.bat` (Windows) or `./setup.sh` (Linux/Mac)!
