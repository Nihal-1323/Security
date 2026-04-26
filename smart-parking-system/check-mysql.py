#!/usr/bin/env python3
"""
Quick MySQL Status Checker
Checks if MySQL is running and accessible
"""

import sys

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    END = '\033[0m'

def check_mysql():
    """Check MySQL connection"""
    try:
        import mysql.connector
    except ImportError:
        print(f"{Colors.YELLOW}Installing mysql-connector-python...{Colors.END}")
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "mysql-connector-python", "-q"])
        import mysql.connector
    
    print(f"\n{Colors.CYAN}Checking MySQL connection...{Colors.END}\n")
    
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password=""
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT VERSION()")
        version = cursor.fetchone()[0]
        
        print(f"{Colors.GREEN}✓ MySQL is running!{Colors.END}")
        print(f"  Version: {version}")
        print(f"  Host: localhost")
        print(f"  User: root")
        
        # Check if database exists
        cursor.execute("SHOW DATABASES LIKE 'smart_parking_db'")
        db_exists = cursor.fetchone()
        
        if db_exists:
            print(f"\n{Colors.GREEN}✓ Database 'smart_parking_db' exists{Colors.END}")
            
            # Check tables
            cursor.execute("USE smart_parking_db")
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            print(f"  Tables: {len(tables)}")
            
            if len(tables) >= 5:
                print(f"\n{Colors.GREEN}✓ All tables created{Colors.END}")
                print(f"\n{Colors.CYAN}System is ready! You can access:{Colors.END}")
                print(f"  http://localhost/smart-parking-system/test-connection.php")
            else:
                print(f"\n{Colors.YELLOW}⚠ Database exists but tables are missing{Colors.END}")
                print(f"  Please import database/schema.sql")
        else:
            print(f"\n{Colors.YELLOW}⚠ Database 'smart_parking_db' not found{Colors.END}")
            print(f"  Run setup.py to create it")
        
        cursor.close()
        conn.close()
        
        return True
        
    except mysql.connector.Error as e:
        if "Access denied" in str(e):
            print(f"{Colors.RED}✗ MySQL is running but requires a password{Colors.END}")
            print(f"\nPlease update config/database.php with your MySQL password")
        elif "Can't connect" in str(e) or "Connection refused" in str(e):
            print(f"{Colors.RED}✗ MySQL is not running{Colors.END}")
            print(f"\nPlease start MySQL:")
            print(f"  1. Open XAMPP Control Panel")
            print(f"  2. Click 'Start' for MySQL")
            print(f"  3. Wait for it to turn green")
            print(f"  4. Run this script again")
        else:
            print(f"{Colors.RED}✗ MySQL connection failed: {e}{Colors.END}")
        
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("  Smart Parking System - MySQL Status Checker")
    print("=" * 60)
    
    if check_mysql():
        print(f"\n{Colors.GREEN}MySQL is ready for installation!{Colors.END}")
        print(f"\nRun: {Colors.CYAN}python setup.py{Colors.END} to install the system\n")
        sys.exit(0)
    else:
        print(f"\n{Colors.YELLOW}Please fix the issues above and try again{Colors.END}\n")
        sys.exit(1)
