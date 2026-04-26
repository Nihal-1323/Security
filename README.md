# 🚗 Smart Parking Management System

A complete web-based parking management system with user registration, real-time slot booking, payment tracking, and role-based access control.

![Smart Parking System](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

## ✨ Features

### 👤 User Features
- User registration and login
- View real-time parking slot availability
- Book parking slots
- View booking history
- Make payments
- Extend booking time

### 🔒 Security Staff Features
- Check in/out vehicles
- View all active bookings
- Search by vehicle number
- Activity logging

### ⚙️ Admin Features
- Manage users
- Manage parking slots
- View all bookings and payments
- Generate reports
- Activity logs

## 🚀 Quick Start

### Requirements
- Windows PC
- XAMPP (Apache + MySQL + PHP)
- Modern web browser

### Installation (5 Minutes)

1. **Install XAMPP**
   - Download from: https://www.apachefriends.org/
   - Install to: `C:\xampp` (default location)

2. **Download This Project**
   - Click the green "Code" button above
   - Click "Download ZIP"
   - Extract the ZIP file

3. **Copy to XAMPP**
   - Find the `smart-parking-system` folder in the extracted files
   - Copy it to: `C:\xampp\htdocs\`
   - Final path: `C:\xampp\htdocs\smart-parking-system\`

4. **Start XAMPP Services**
   - Open XAMPP Control Panel
   - Click "Start" for Apache (wait for GREEN)
   - Click "Start" for MySQL (wait for GREEN)

5. **Run Automated Setup**
   - Go to: `C:\xampp\htdocs\smart-parking-system\`
   - Double-click: `setup.bat`
   - Wait for "Setup completed successfully!"
   - This creates the database and adds 14 parking slots

6. **Open in Browser**
   ```
   http://localhost/smart-parking-system/
   ```

### Verify Installation

Open this URL to verify everything is working:
```
http://localhost/smart-parking-system/test-connection.php
```

You should see:
- ✓ Database connection successful
- ✓ All 5 tables exist
- ✓ parking_slots: 14 rows
- ✓ Admin user found

If parking_slots shows 0 rows, run `setup.bat` again.

## 📖 Documentation

- **[HOW-TO-RUN.txt](smart-parking-system/HOW-TO-RUN.txt)** - Complete setup guide
- **[QUICKSTART.txt](smart-parking-system/QUICKSTART.txt)** - Quick reference
- **[TROUBLESHOOTING.md](smart-parking-system/TROUBLESHOOTING.md)** - Common issues and fixes
- **[SETUP.md](smart-parking-system/SETUP.md)** - Detailed setup instructions

## 🔐 Default Admin Account

```
Username: admin
Password: Admin@2026
Role: Admin
```

⚠️ **Important:** Change this password after first login!

## 🗄️ Database

- **Database Name:** smart_parking_db
- **Tables:** 5 (users, parking_slots, bookings, payments, activity_logs)
- **Parking Slots:** 14 (A1-A4, B1-B4, C1-C3, D1-D3)

## 🛠️ Tech Stack

- **Frontend:** HTML5, CSS3, JavaScript (ES6+)
- **Backend:** PHP 7.4+
- **Database:** MySQL 5.7+
- **Server:** Apache (via XAMPP)

## 📁 Project Structure

```
smart-parking-system/
├── api/                    # Backend API endpoints
│   ├── auth.php           # Authentication
│   ├── slots.php          # Parking slots management
│   ├── bookings.php       # Booking management
│   └── users.php          # User management
├── config/                # Configuration files
│   └── database.php       # Database connection
├── css/                   # Stylesheets
├── js/                    # JavaScript files
├── database/              # Database schema
│   └── schema.sql         # SQL schema
├── index.html             # Homepage
├── login.html             # Login page
├── register.html          # Registration page
├── dashboard.html         # Dashboard
└── setup.bat              # Automated setup script
```

## 🔧 Troubleshooting

### Site not loading?
- Check if Apache is running (green in XAMPP)
- Verify files are in `C:\xampp\htdocs\smart-parking-system\`

### Connection error?
- Check if MySQL is running (green in XAMPP)
- Run `import-database.bat`

### MySQL won't start?
- Run `diagnose-mysql.bat`
- Run `fix-mysql.bat`

For more help, see [TROUBLESHOOTING.md](smart-parking-system/TROUBLESHOOTING.md)

## 🧪 Testing

Test the system:
```
http://localhost/smart-parking-system/test-connection.php
```

All checks should show ✓ (green checkmarks)

## 📦 Automated Setup Scripts

- `setup.bat` - Complete automated setup
- `setup.py` - Python setup script (cross-platform)
- `setup.sh` - Linux/Mac setup script
- `import-database.bat` - Import database only
- `diagnose-mysql.bat` - Diagnose MySQL issues
- `fix-mysql.bat` - Fix common MySQL problems

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📄 License

This project is open source and available for educational purposes.

## 👨‍💻 Author

**Nihal**
- GitHub: [@Nihal-1323](https://github.com/Nihal-1323)

## 🙏 Acknowledgments

Built with ❤️ for efficient parking management

---

**Need Help?** Check the documentation files or open an issue on GitHub.

**Enjoy!** 🚗💨
