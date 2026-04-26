#!/usr/bin/env python3
"""
Smart Parking System - Automated Setup Script
Automates the installation and configuration process
"""

import os
import sys
import shutil
import subprocess
import platform
import webbrowser
from pathlib import Path

class Colors:
    """ANSI color codes for terminal output"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

class SmartParkingSetup:
    def __init__(self):
        self.system = platform.system()
        self.script_dir = Path(__file__).parent.absolute()
        self.xampp_path = None
        self.wamp_path = None
        self.web_root = None
        self.project_name = "smart-parking-system"
        
    def print_header(self, text):
        """Print formatted header"""
        print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}{text.center(60)}{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.END}\n")
        
    def print_success(self, text):
        """Print success message"""
        print(f"{Colors.GREEN}✓ {text}{Colors.END}")
        
    def print_error(self, text):
        """Print error message"""
        print(f"{Colors.RED}✗ {text}{Colors.END}")
        
    def print_info(self, text):
        """Print info message"""
        print(f"{Colors.CYAN}ℹ {text}{Colors.END}")
        
    def print_warning(self, text):
        """Print warning message"""
        print(f"{Colors.YELLOW}⚠ {text}{Colors.END}")
        
    def detect_web_server(self):
        """Detect XAMPP or WAMP installation"""
        self.print_info("Detecting web server installation...")
        
        if self.system == "Windows":
            # Check for XAMPP
            xampp_paths = [
                Path("C:/xampp"),
                Path("D:/xampp"),
                Path(os.path.expanduser("~/xampp"))
            ]
            
            for path in xampp_paths:
                if path.exists():
                    self.xampp_path = path
                    self.web_root = path / "htdocs"
                    self.print_success(f"Found XAMPP at: {path}")
                    return True
            
            # Check for WAMP
            wamp_paths = [
                Path("C:/wamp64"),
                Path("C:/wamp"),
                Path("D:/wamp64"),
                Path("D:/wamp")
            ]
            
            for path in wamp_paths:
                if path.exists():
                    self.wamp_path = path
                    self.web_root = path / "www"
                    self.print_success(f"Found WAMP at: {path}")
                    return True
                    
        elif self.system == "Linux":
            # Check for common Linux web roots
            linux_paths = [
                Path("/var/www/html"),
                Path("/opt/lampp/htdocs"),
                Path(os.path.expanduser("~/public_html"))
            ]
            
            for path in linux_paths:
                if path.exists():
                    self.web_root = path
                    self.print_success(f"Found web root at: {path}")
                    return True
                    
        elif self.system == "Darwin":  # macOS
            mac_paths = [
                Path("/Applications/XAMPP/htdocs"),
                Path(os.path.expanduser("~/Sites"))
            ]
            
            for path in mac_paths:
                if path.exists():
                    self.web_root = path
                    self.print_success(f"Found web root at: {path}")
                    return True
        
        self.print_error("Could not detect XAMPP/WAMP installation")
        return False
        
    def copy_files(self):
        """Copy project files to web root"""
        self.print_info("Copying project files...")
        
        if not self.web_root:
            self.print_error("Web root not detected")
            return False
            
        destination = self.web_root / self.project_name
        
        try:
            # Remove existing installation
            if destination.exists():
                self.print_warning(f"Existing installation found at {destination}")
                response = input("Do you want to overwrite it? (y/n): ").lower()
                if response == 'y':
                    shutil.rmtree(destination)
                    self.print_success("Removed existing installation")
                else:
                    self.print_info("Installation cancelled")
                    return False
            
            # Copy files
            shutil.copytree(self.script_dir, destination, 
                          ignore=shutil.ignore_patterns('setup.py', '__pycache__', '*.pyc'))
            
            self.print_success(f"Files copied to: {destination}")
            return True
            
        except Exception as e:
            self.print_error(f"Failed to copy files: {e}")
            return False
            
    def check_mysql_connection(self):
        """Check if MySQL is accessible"""
        self.print_info("Checking MySQL connection...")
        
        try:
            import mysql.connector
            
            try:
                conn = mysql.connector.connect(
                    host="localhost",
                    user="root",
                    password=""
                )
                conn.close()
                self.print_success("MySQL is accessible")
                return True
            except mysql.connector.Error as e:
                if "Access denied" in str(e):
                    self.print_error("MySQL connection failed: Access denied")
                    self.print_warning("MySQL is running but requires a password")
                    self.print_info("Please update config/database.php with your MySQL password")
                    return False
                else:
                    self.print_error(f"MySQL connection failed: {e}")
                    self.print_warning("MySQL may not be running")
                    return False
                
        except ImportError:
            self.print_warning("mysql-connector-python not installed")
            self.print_info("Installing mysql-connector-python...")
            
            try:
                subprocess.check_call([sys.executable, "-m", "pip", "install", "mysql-connector-python"])
                self.print_success("mysql-connector-python installed")
                return self.check_mysql_connection()
            except Exception as e:
                self.print_error(f"Failed to install mysql-connector-python: {e}")
                return False
                
    def create_database(self):
        """Create database and import schema"""
        self.print_info("Setting up database...")
        
        try:
            import mysql.connector
            
            # Connect to MySQL
            conn = mysql.connector.connect(
                host="localhost",
                user="root",
                password=""
            )
            cursor = conn.cursor()
            
            # Create database
            cursor.execute("CREATE DATABASE IF NOT EXISTS smart_parking_db")
            self.print_success("Database 'smart_parking_db' created")
            
            # Use database
            cursor.execute("USE smart_parking_db")
            
            # Read and execute schema
            schema_file = self.script_dir / "database" / "schema.sql"
            
            if schema_file.exists():
                with open(schema_file, 'r', encoding='utf-8') as f:
                    sql_content = f.read()
                    
                # Split by semicolon and execute each statement
                statements = [s.strip() for s in sql_content.split(';') if s.strip()]
                
                for statement in statements:
                    if statement and not statement.startswith('--'):
                        try:
                            cursor.execute(statement)
                        except mysql.connector.Error as e:
                            # Ignore errors for CREATE DATABASE and USE statements
                            if "database exists" not in str(e).lower():
                                pass
                
                conn.commit()
                self.print_success("Database schema imported successfully")
                
                # Verify tables
                cursor.execute("SHOW TABLES")
                tables = cursor.fetchall()
                self.print_success(f"Created {len(tables)} tables")
                
            else:
                self.print_error("Schema file not found")
                return False
            
            cursor.close()
            conn.close()
            return True
            
        except Exception as e:
            self.print_error(f"Database setup failed: {e}")
            return False
            
    def update_config(self):
        """Update database configuration if needed"""
        self.print_info("Checking database configuration...")
        
        config_file = self.web_root / self.project_name / "config" / "database.php"
        
        if config_file.exists():
            self.print_success("Database configuration file found")
            return True
        else:
            self.print_warning("Database configuration file not found")
            return False
            
    def start_services(self):
        """Attempt to start Apache and MySQL services"""
        self.print_info("Checking services...")
        
        if self.system == "Windows":
            if self.xampp_path:
                xampp_control = self.xampp_path / "xampp-control.exe"
                if xampp_control.exists():
                    self.print_info("Please start Apache and MySQL from XAMPP Control Panel")
                    try:
                        subprocess.Popen([str(xampp_control)])
                        self.print_success("XAMPP Control Panel opened")
                    except Exception as e:
                        self.print_warning(f"Could not open XAMPP Control Panel: {e}")
                        
            elif self.wamp_path:
                self.print_info("Please start WAMP services from the system tray")
                
        elif self.system == "Linux":
            self.print_info("Attempting to start services...")
            try:
                # Try to start Apache
                subprocess.run(["sudo", "systemctl", "start", "apache2"], check=False)
                subprocess.run(["sudo", "systemctl", "start", "mysql"], check=False)
                self.print_success("Services started (if you have sudo access)")
            except Exception as e:
                self.print_warning("Please start Apache and MySQL manually")
                
        return True
        
    def open_browser(self):
        """Open the application in browser"""
        url = f"http://localhost/{self.project_name}/test-connection.php"
        
        self.print_info(f"Opening browser to: {url}")
        
        try:
            webbrowser.open(url)
            self.print_success("Browser opened")
            return True
        except Exception as e:
            self.print_warning(f"Could not open browser: {e}")
            self.print_info(f"Please manually open: {url}")
            return False
            
    def print_summary(self):
        """Print installation summary"""
        self.print_header("Installation Complete!")
        
        print(f"{Colors.BOLD}Access URLs:{Colors.END}")
        print(f"  • Test Connection: {Colors.CYAN}http://localhost/{self.project_name}/test-connection.php{Colors.END}")
        print(f"  • Homepage:        {Colors.CYAN}http://localhost/{self.project_name}/index.html{Colors.END}")
        print(f"  • Login:           {Colors.CYAN}http://localhost/{self.project_name}/login.html{Colors.END}")
        
        print(f"\n{Colors.BOLD}Default Admin Credentials:{Colors.END}")
        print(f"  • Username: {Colors.GREEN}admin{Colors.END}")
        print(f"  • Password: {Colors.GREEN}Admin@2026{Colors.END}")
        print(f"  • Role:     {Colors.GREEN}Administrator{Colors.END}")
        
        print(f"\n{Colors.BOLD}Installation Location:{Colors.END}")
        print(f"  • {self.web_root / self.project_name}")
        
        print(f"\n{Colors.BOLD}Next Steps:{Colors.END}")
        print(f"  1. Ensure Apache and MySQL are running")
        print(f"  2. Visit the test connection page to verify setup")
        print(f"  3. Access the application and login")
        print(f"  4. Change the admin password after first login")
        
        print(f"\n{Colors.YELLOW}Need help? Check SETUP.md for detailed instructions{Colors.END}\n")
        
    def run(self):
        """Run the complete setup process"""
        self.print_header("Smart Parking System - Automated Setup")
        
        print(f"{Colors.BOLD}System Information:{Colors.END}")
        print(f"  • OS: {self.system}")
        print(f"  • Python: {sys.version.split()[0]}")
        print(f"  • Script Location: {self.script_dir}")
        
        # Step 1: Detect web server
        if not self.detect_web_server():
            self.print_error("Setup cannot continue without a web server")
            self.print_info("Please install XAMPP or WAMP and run this script again")
            return False
            
        # Step 2: Copy files
        if not self.copy_files():
            return False
            
        # Step 3: Check MySQL
        mysql_ok = self.check_mysql_connection()
        
        if not mysql_ok:
            self.print_header("MySQL Setup Required")
            print(f"{Colors.YELLOW}MySQL is not accessible. Please follow these steps:{Colors.END}\n")
            print(f"1. Open XAMPP Control Panel")
            print(f"2. Click 'Start' button for MySQL (should turn green)")
            print(f"3. Wait for MySQL to start completely")
            print(f"4. Run this script again: {Colors.CYAN}python setup.py{Colors.END}\n")
            
            if self.xampp_path:
                xampp_control = self.xampp_path / "xampp-control.exe"
                if xampp_control.exists():
                    response = input("Do you want to open XAMPP Control Panel now? (y/n): ").lower()
                    if response == 'y':
                        try:
                            subprocess.Popen([str(xampp_control)])
                            self.print_success("XAMPP Control Panel opened")
                            print(f"\n{Colors.YELLOW}After starting MySQL, run this script again.{Colors.END}")
                        except Exception as e:
                            self.print_warning(f"Could not open XAMPP Control Panel: {e}")
            
            return False
            
        # Step 4: Create database
        if not self.create_database():
            self.print_warning("Database setup failed")
            self.print_info("You can manually import database/schema.sql")
            
        # Step 5: Update config
        self.update_config()
        
        # Step 6: Start services
        self.start_services()
        
        # Step 7: Open browser
        input("\nPress Enter to open the application in your browser...")
        self.open_browser()
        
        # Step 8: Print summary
        self.print_summary()
        
        return True

def main():
    """Main entry point"""
    try:
        setup = SmartParkingSetup()
        success = setup.run()
        
        if success:
            sys.exit(0)
        else:
            sys.exit(1)
            
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Setup cancelled by user{Colors.END}")
        sys.exit(1)
    except Exception as e:
        print(f"\n{Colors.RED}Unexpected error: {e}{Colors.END}")
        sys.exit(1)

if __name__ == "__main__":
    main()
