# Smart Parking System - MySQL Backend Setup Guide

## Prerequisites

- XAMPP or WAMP installed
- Apache and MySQL running
- Modern web browser

## Installation Steps

### Step 1: Setup Files

1. Copy the `smart-parking-system` folder to your web server directory:
   - **XAMPP:** `C:\xampp\htdocs\smart-parking-system\`
   - **WAMP:** `C:\wamp64\www\smart-parking-system\`

### Step 2: Create Database

1. Start Apache and MySQL in XAMPP/WAMP Control Panel
2. Open phpMyAdmin: `http://localhost/phpmyadmin`
3. Click "Import" tab
4. Choose file: `database/schema.sql`
5. Click "Go" button
6. Wait for success message

**OR** use MySQL command line:
```bash
mysql -u root -p < database/schema.sql
```

### Step 3: Configure Database Connection

1. Open `config/database.php`
2. Update credentials if needed:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');  // Your MySQL password
define('DB_NAME', 'smart_parking_db');
```

### Step 4: Access the Application

1. Open browser
2. Go to: `http://localhost/smart-parking-system/index.html`
3. Register a new account or use admin credentials

## Default Admin Credentials

**Username:** admin  
**Password:** Admin@2026  
**Role:** Administrator

**Important:** Change the admin password after first login!

## Project Structure

```
smart-parking-system/
├── index.html              # Homepage
├── login.html              # Login page
├── register.html           # Registration page
├── dashboard.html          # Dashboard
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

## Database Schema

### Tables Created:

1. **users** - User accounts (admin, security, user)
2. **parking_slots** - Parking slot information
3. **bookings** - Parking reservations
4. **payments** - Payment records
5. **activity_logs** - System activity logs

### Default Data:

- 1 Admin user
- 14 Parking slots (A1-A4, B1-B4, C1-C4, D1-D2)

## Features

### For Users:
- Register and login
- View available parking slots
- Book parking slots
- View booking history
- Cancel active bookings

### For Security Staff:
- View all parking slots
- Process vehicle entry/exit
- Calculate parking fees automatically
- View activity logs

### For Administrators:
- Complete dashboard with statistics
- Manage all parking slots
- View all registered users
- Monitor all bookings
- Access system logs

## API Endpoints

### Authentication
- `POST api/auth.php?action=login` - User login
- `POST api/auth.php?action=register` - User registration
- `GET api/auth.php?action=logout` - User logout
- `GET api/auth.php?action=check` - Check session

### Parking Slots
- `GET api/slots.php?action=getAll` - Get all slots
- `GET api/slots.php?action=getAvailable` - Get available slots
- `GET api/slots.php?action=getStats` - Get slot statistics
- `POST api/slots.php?action=updateStatus` - Update slot status

### Bookings
- `POST api/bookings.php?action=create` - Create booking
- `GET api/bookings.php?action=getMyBookings` - Get user bookings
- `GET api/bookings.php?action=getAllBookings` - Get all bookings (admin)
- `POST api/bookings.php?action=cancel` - Cancel booking
- `POST api/bookings.php?action=processExit` - Process exit (security)
- `GET api/bookings.php?action=getActive` - Get active bookings

### Users
- `GET api/users.php?action=getAll` - Get all users (admin)
- `GET api/users.php?action=getStats` - Get user statistics
- `POST api/users.php?action=updateStatus` - Update user status

## Troubleshooting

### Database Connection Failed
- Check MySQL is running in XAMPP/WAMP
- Verify database credentials in `config/database.php`
- Ensure database `smart_parking_db` exists

### API Not Working
- Check Apache is running
- Verify file paths are correct
- Check browser console for errors
- Ensure PHP is enabled

### Login Not Working
- Verify database is imported correctly
- Check users table has admin account
- Clear browser cache and cookies

### Slots Not Loading
- Check database connection
- Verify parking_slots table has data
- Check browser console for API errors

## Security Notes

### Current Implementation:
- Password hashing using PHP `password_hash()`
- SQL injection prevention using prepared statements
- Session-based authentication
- Role-based access control

### For Production:
- Use HTTPS
- Implement CSRF tokens
- Add rate limiting
- Use environment variables for credentials
- Enable error logging
- Implement backup system

## Parking Fee Calculation

- **Rate:** ₹20 per hour
- **Calculation:** Rounded up to nearest hour
- **Example:** 2.5 hours = 3 hours = ₹60

## Browser Compatibility

- ✅ Chrome (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge
- ✅ Opera

## Support

### Common Issues:

1. **HTTP 500 Error**
   - Check PHP error logs
   - Verify database connection
   - Check file permissions

2. **Blank Page**
   - Enable error display in php.ini
   - Check browser console
   - Verify all files are uploaded

3. **Session Issues**
   - Check session.save_path in php.ini
   - Verify cookies are enabled
   - Clear browser data

## Version

Version 2.0.0 - MySQL Backend Implementation

## License

© 2026 Smart Parking Management System. All Rights Reserved.

---

**Need Help?** Check the browser console and PHP error logs for detailed error messages.
