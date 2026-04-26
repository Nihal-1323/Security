#!/bin/bash
# Smart Parking System - Linux/Mac Setup Script
# Automated installation for Linux and macOS

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Variables
PROJECT_NAME="smart-parking-system"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT=""

# Functions
print_header() {
    echo -e "\n${BOLD}============================================================${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${BOLD}============================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Detect web server
detect_web_server() {
    print_info "Detecting web server installation..."
    
    # Check for common Linux paths
    if [ -d "/var/www/html" ]; then
        WEB_ROOT="/var/www/html"
        print_success "Found web root at: $WEB_ROOT"
        return 0
    fi
    
    # Check for XAMPP on Linux
    if [ -d "/opt/lampp/htdocs" ]; then
        WEB_ROOT="/opt/lampp/htdocs"
        print_success "Found XAMPP at: /opt/lampp"
        return 0
    fi
    
    # Check for macOS paths
    if [ -d "/Applications/XAMPP/htdocs" ]; then
        WEB_ROOT="/Applications/XAMPP/htdocs"
        print_success "Found XAMPP at: /Applications/XAMPP"
        return 0
    fi
    
    if [ -d "$HOME/Sites" ]; then
        WEB_ROOT="$HOME/Sites"
        print_success "Found web root at: $WEB_ROOT"
        return 0
    fi
    
    print_error "Could not detect web server installation"
    return 1
}

# Copy files
copy_files() {
    print_info "Copying project files..."
    
    DESTINATION="$WEB_ROOT/$PROJECT_NAME"
    
    # Check if destination exists
    if [ -d "$DESTINATION" ]; then
        print_warning "Installation already exists at $DESTINATION"
        read -p "Do you want to overwrite it? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            return 1
        fi
        print_info "Removing existing installation..."
        rm -rf "$DESTINATION"
    fi
    
    # Copy files
    cp -r "$SCRIPT_DIR" "$DESTINATION"
    
    # Remove setup scripts from destination
    rm -f "$DESTINATION/setup.sh"
    rm -f "$DESTINATION/setup.py"
    rm -f "$DESTINATION/setup.bat"
    
    print_success "Files copied to: $DESTINATION"
    return 0
}

# Check MySQL
check_mysql() {
    print_info "Checking MySQL connection..."
    
    if command -v mysql &> /dev/null; then
        if mysql -u root -e "SELECT 1" &> /dev/null; then
            print_success "MySQL is accessible"
            return 0
        else
            print_warning "MySQL requires password or is not running"
            return 1
        fi
    else
        print_error "MySQL client not found"
        return 1
    fi
}

# Create database
create_database() {
    print_info "Setting up database..."
    
    SCHEMA_FILE="$SCRIPT_DIR/database/schema.sql"
    
    if [ ! -f "$SCHEMA_FILE" ]; then
        print_error "Schema file not found"
        return 1
    fi
    
    # Try to import without password
    if mysql -u root < "$SCHEMA_FILE" 2>/dev/null; then
        print_success "Database created successfully"
        return 0
    else
        print_warning "Failed to create database automatically"
        print_info "Please import manually: mysql -u root -p < $SCHEMA_FILE"
        return 1
    fi
}

# Start services
start_services() {
    print_info "Checking services..."
    
    # Check if running as root or with sudo
    if [ "$EUID" -eq 0 ]; then
        # Try to start Apache
        if command -v systemctl &> /dev/null; then
            systemctl start apache2 2>/dev/null || systemctl start httpd 2>/dev/null
            systemctl start mysql 2>/dev/null || systemctl start mariadb 2>/dev/null
            print_success "Services started"
        elif command -v service &> /dev/null; then
            service apache2 start 2>/dev/null || service httpd start 2>/dev/null
            service mysql start 2>/dev/null || service mariadb start 2>/dev/null
            print_success "Services started"
        fi
    else
        print_warning "Not running as root, cannot start services automatically"
        print_info "Please start Apache and MySQL manually or run with sudo"
    fi
    
    # Check for XAMPP on Linux
    if [ -f "/opt/lampp/lampp" ]; then
        print_info "XAMPP detected. You can start it with: sudo /opt/lampp/lampp start"
    fi
    
    return 0
}

# Open browser
open_browser() {
    URL="http://localhost/$PROJECT_NAME/test-connection.php"
    
    print_info "Opening browser to: $URL"
    
    # Detect OS and open browser
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "$URL" &> /dev/null &
            print_success "Browser opened"
        else
            print_warning "Could not open browser automatically"
            print_info "Please open: $URL"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        open "$URL"
        print_success "Browser opened"
    fi
}

# Print summary
print_summary() {
    print_header "Installation Complete!"
    
    echo -e "${BOLD}Access URLs:${NC}"
    echo -e "  • Test Connection: ${CYAN}http://localhost/$PROJECT_NAME/test-connection.php${NC}"
    echo -e "  • Homepage:        ${CYAN}http://localhost/$PROJECT_NAME/index.html${NC}"
    echo -e "  • Login:           ${CYAN}http://localhost/$PROJECT_NAME/login.html${NC}"
    
    echo -e "\n${BOLD}Default Admin Credentials:${NC}"
    echo -e "  • Username: ${GREEN}admin${NC}"
    echo -e "  • Password: ${GREEN}Admin@2026${NC}"
    echo -e "  • Role:     ${GREEN}Administrator${NC}"
    
    echo -e "\n${BOLD}Installation Location:${NC}"
    echo -e "  • $WEB_ROOT/$PROJECT_NAME"
    
    echo -e "\n${BOLD}Next Steps:${NC}"
    echo -e "  1. Ensure Apache and MySQL are running"
    echo -e "  2. Visit the test connection page to verify setup"
    echo -e "  3. Access the application and login"
    echo -e "  4. Change the admin password after first login"
    
    echo -e "\n${YELLOW}Need help? Check SETUP.md for detailed instructions${NC}\n"
}

# Main execution
main() {
    print_header "Smart Parking System - Automated Setup"
    
    echo -e "${BOLD}System Information:${NC}"
    echo -e "  • OS: $(uname -s)"
    echo -e "  • Script Location: $SCRIPT_DIR"
    
    # Check for Python and run Python script if available
    if command -v python3 &> /dev/null; then
        print_info "Python 3 detected, you can also run: python3 setup.py"
    fi
    
    # Step 1: Detect web server
    if ! detect_web_server; then
        print_error "Setup cannot continue without a web server"
        print_info "Please install Apache/XAMPP and run this script again"
        exit 1
    fi
    
    # Step 2: Copy files
    if ! copy_files; then
        exit 1
    fi
    
    # Step 3: Check MySQL
    if ! check_mysql; then
        print_warning "MySQL is not accessible"
        print_info "Please start MySQL and import database/schema.sql manually"
    else
        # Step 4: Create database
        create_database
    fi
    
    # Step 5: Start services
    start_services
    
    # Step 6: Database import instructions
    echo ""
    print_header "Database Setup"
    echo "If automatic database creation failed, please:"
    echo "1. Open phpMyAdmin: http://localhost/phpmyadmin"
    echo "2. Import: $WEB_ROOT/$PROJECT_NAME/database/schema.sql"
    echo ""
    read -p "Press Enter to continue..."
    
    # Step 7: Open browser
    open_browser
    
    # Step 8: Print summary
    print_summary
}

# Run main function
main
