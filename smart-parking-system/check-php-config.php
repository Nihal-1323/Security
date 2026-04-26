<?php
// Check PHP Configuration
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h2>PHP Configuration Check</h2>";

// Check PHP version
echo "<h3>PHP Version</h3>";
echo "PHP Version: " . phpversion() . "<br>";

// Check required extensions
echo "<h3>Required Extensions</h3>";
$extensions = ['mysqli', 'json', 'session'];
foreach ($extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "✓ $ext extension loaded<br>";
    } else {
        echo "✗ $ext extension NOT loaded<br>";
    }
}

// Check session configuration
echo "<h3>Session Configuration</h3>";
echo "session.save_path: " . ini_get('session.save_path') . "<br>";
echo "session.use_cookies: " . ini_get('session.use_cookies') . "<br>";
echo "session.use_only_cookies: " . ini_get('session.use_only_cookies') . "<br>";

// Test session start
echo "<h3>Session Test</h3>";
if (session_status() === PHP_SESSION_NONE) {
    if (session_start()) {
        echo "✓ Session started successfully<br>";
        echo "Session ID: " . session_id() . "<br>";
    } else {
        echo "✗ Session start FAILED<br>";
    }
} else {
    echo "✓ Session already active<br>";
}

// Check error log location
echo "<h3>Error Logging</h3>";
echo "error_log location: " . ini_get('error_log') . "<br>";
echo "log_errors: " . ini_get('log_errors') . "<br>";
echo "display_errors: " . ini_get('display_errors') . "<br>";

// Check file permissions
echo "<h3>File Permissions</h3>";
$files = [
    'config/database.php',
    'api/auth.php',
    'api/slots.php',
    'api/bookings.php',
    'api/users.php'
];

foreach ($files as $file) {
    if (file_exists($file)) {
        $perms = fileperms($file);
        echo "✓ $file - " . substr(sprintf('%o', $perms), -4) . "<br>";
    } else {
        echo "✗ $file NOT FOUND<br>";
    }
}

// Check database connection
echo "<h3>Database Connection</h3>";
if (file_exists('config/database.php')) {
    require_once 'config/database.php';
    $conn = getDBConnection();
    if ($conn) {
        echo "✓ Database connection successful<br>";
        echo "Database: " . DB_NAME . "<br>";
        
        // Check tables
        $tables = ['users', 'parking_slots', 'bookings', 'payments', 'activity_logs'];
        foreach ($tables as $table) {
            $result = $conn->query("SHOW TABLES LIKE '$table'");
            if ($result && $result->num_rows > 0) {
                echo "✓ Table '$table' exists<br>";
            } else {
                echo "✗ Table '$table' NOT FOUND<br>";
            }
        }
        
        closeDBConnection($conn);
    } else {
        echo "✗ Database connection FAILED<br>";
    }
}

echo "<h3>Summary</h3>";
echo "<p>If all checks pass, the system should work correctly.</p>";
echo "<p>If you see errors, check the Apache error log at: C:\\xampp\\apache\\logs\\error.log</p>";
?>
