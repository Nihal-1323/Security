# Smart Parking Management System

A modern, fully functional parking management system with MySQL backend, built with HTML, CSS, JavaScript, and PHP.

## 🚀 Features

### For All Users
- 🏠 Beautiful homepage with real-time parking availability
- 🔐 Secure login and registration system
- 📱 Fully responsive design
- 🎨 Modern UI with smooth animations
- 💾 MySQL database backend

### For Regular Users
- View available parking slots in real-time
- Book parking slots instantly
- View booking history
- Cancel active bookings
- Track parking payments

### For Security Staff
- Monitor all parking slots
- Process vehicle entry and exit
- View activity logs
- Manage active bookings
- Calculate parking fees automatically

### For Administrators
- Complete dashboard with statistics
- Manage all parking slots
- View all registered users
- Monitor all bookings
- Track revenue and activity logs

## 📋 Requirements

- XAMPP or WAMP (Apache + MySQL + PHP)
- Modern web browser
- PHP 7.4 or higher
- MySQL 5.7 or higher

## 🔧 Installation

### Quick Setup

1. **Copy files to web server:**
   - XAMPP: `C:\xampp\htdocs\smart-parking-system\`
   - WAMP: `C:\wamp64\www\smart-parking-system\`

2. **Start servers:**
   - Open XAMPP/WAMP Control Panel
   - Start Apache
   - Start MySQL

3. **Import database:**
   - Open `http://localhost/phpmyadmin`
   - Click "Import"
   - Choose `database/schema.sql`
   - Click "Go"

4. **Test connection:**
   - Open `http://localhost/smart-parking-system/test-connection.php`
   - Verify all checks pass

5. **Access application:**
   - Open `http://localhost/smart-parking-system/index.html`

### Detailed Setup

See [SETUP.md](SETUP.md) for complete installation instructions.

## 🔑 Default Admin Credentials

**Username:** admin  
**Password:** Admin@2026  
**Role:** Administrator

**⚠️ Important:** Change the admin password after first login!

## 📁 Project Structure

```
smart-parking-system/
├── index.html              # Homepage
├── login.html              # Login page
├── register.html           # Registration page
├── dashboard.html          # User dashboard
├── test-connection.php     # Database test
├── config/
│   └── database.php        # Database configuration
├── api/
│   ├── auth.php            # Authentication API
│   ├── slots.php           # Parking slots API
│   ├── bookings.php        # Bookings API
│   └── users.php           # Users API
├── database/
│   └── schema.sql          # Database schema
├── css/
│   ├── style.css           # Homepage styles
│   ├── auth.css            # Auth pages styles
│   └── dashboard.css       # Dashboard styles
└── js/
    ├── main.js             # Homepage functionality
    ├── auth.js             # Authentication logic
    └── dashboard-mysql.js  # Dashboard with MySQL
```

## 🗄️ Database Schema

### Tables:
- **users** - User accounts with roles
- **parking_slots** - Parking slot information
- **bookings** - Parking reservations
- **payments** - Payment records
- **activity_logs** - System activity tracking

### Default Data:
- 1 Admin user
- 14 Parking slots (A1-D2)

## 🔌 API Endpoints

### Authentication
- `POST /api/auth.php?action=login`
- `POST /api/auth.php?action=register`
- `GET /api/auth.php?action=logout`

### Parking Slots
- `GET /api/slots.php?action=getAll`
- `GET /api/slots.php?action=getAvailable`
- `GET /api/slots.php?action=getStats`

### Bookings
- `POST /api/bookings.php?action=create`
- `GET /api/bookings.php?action=getMyBookings`
- `POST /api/bookings.php?action=cancel`
- `POST /api/bookings.php?action=processExit`

### Users (Admin only)
- `GET /api/users.php?action=getAll`
- `GET /api/users.php?action=getStats`

## 💰 Parking Fee Calculation

- **Rate:** ₹20 per hour
- **Calculation:** Rounded up to nearest hour
- **Example:** 2.5 hours = 3 hours = ₹60

## 🔒 Security Features

- Password hashing using PHP `password_hash()`
- SQL injection prevention with prepared statements
- Session-based authentication
- Role-based access control
- Activity logging

## 🌐 Browser Compatibility

- ✅ Chrome (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge
- ✅ Opera

## 🐛 Troubleshooting

### Database Connection Failed
1. Check MySQL is running
2. Verify credentials in `config/database.php`
3. Ensure database exists

### API Not Working
1. Check Apache is running
2. Verify file paths
3. Check browser console

### Login Issues
1. Verify database is imported
2. Check admin user exists
3. Clear browser cache

## 📝 License

© 2026 Smart Parking Management System. All Rights Reserved.

## 🆚 Version

Version 2.0.0 - MySQL Backend Implementation

---

**Need Help?** Run `test-connection.php` to diagnose issues.

**Enjoy using Smart Parking System! 🚗**
