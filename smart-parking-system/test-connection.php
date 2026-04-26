<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Database Connection Test</title>
<style>
body {
    font-family: Arial, sans-serif;
    max-width: 800px;
    margin: 50px auto;
    padding: 20px;
    background: #f5f7fa;
}
.container {
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}
h1 {
    color: #667eea;
}
.success {
    background: #d4edda;
    color: #155724;
    padding: 15px;
    border-radius: 5px;
    margin: 10px 0;
}
.error {
    background: #f8d7da;
    color: #721c24;
    padding: 15px;
    border-radius: 5px;
    margin: 10px 0;
}
.info {
    background: #d1ecf1;
    color: #0c5460;
    padding: 15px;
    border-radius: 5px;
    margin: 10px 0;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
}
th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}
th {
    background: #f8f9fa;
}
</style>
</head>
<body>

<div class="container">
    <h1>🚗 Smart Parking System - Connection Test</h1>
    
    <?php
    require_once 'config/database.php';
    
    echo "<h2>Testing Database Connection...</h2>";
    
    $conn = getDBConnection();
    
    if ($conn) {
        echo '<div class="success">✓ Database connection successful!</div>';
        
        // Test tables
        echo "<h3>Checking Tables:</h3>";
        $tables = ['users', 'parking_slots', 'bookings', 'payments', 'activity_logs'];
        
        echo "<table>";
        echo "<tr><th>Table Name</th><th>Status</th><th>Row Count</th></tr>";
        
        foreach ($tables as $table) {
            $query = "SELECT COUNT(*) as count FROM $table";
            $result = $conn->query($query);
            
            if ($result) {
                $row = $result->fetch_assoc();
                $count = $row['count'];
                echo "<tr><td>$table</td><td style='color: green;'>✓ Exists</td><td>$count rows</td></tr>";
            } else {
                echo "<tr><td>$table</td><td style='color: red;'>✗ Not Found</td><td>-</td></tr>";
            }
        }
        
        echo "</table>";
        
        // Check admin user
        echo "<h3>Checking Admin User:</h3>";
        $adminQuery = "SELECT username, email, role FROM users WHERE role = 'admin' LIMIT 1";
        $adminResult = $conn->query($adminQuery);
        
        if ($adminResult && $adminResult->num_rows > 0) {
            $admin = $adminResult->fetch_assoc();
            echo '<div class="success">✓ Admin user found!</div>';
            echo "<p><strong>Username:</strong> " . $admin['username'] . "</p>";
            echo "<p><strong>Email:</strong> " . $admin['email'] . "</p>";
        } else {
            echo '<div class="error">✗ Admin user not found. Please import database schema.</div>';
        }
        
        // Check parking slots
        echo "<h3>Parking Slots Status:</h3>";
        $slotsQuery = "SELECT status, COUNT(*) as count FROM parking_slots GROUP BY status";
        $slotsResult = $conn->query($slotsQuery);
        
        if ($slotsResult) {
            echo "<table>";
            echo "<tr><th>Status</th><th>Count</th></tr>";
            while ($row = $slotsResult->fetch_assoc()) {
                echo "<tr><td>" . ucfirst($row['status']) . "</td><td>" . $row['count'] . "</td></tr>";
            }
            echo "</table>";
        }
        
        closeDBConnection($conn);
        
        echo '<div class="info">';
        echo '<h3>✓ System Ready!</h3>';
        echo '<p>Your Smart Parking System is properly configured.</p>';
        echo '<p><a href="index.html" style="color: #667eea; font-weight: bold;">Go to Homepage →</a></p>';
        echo '</div>';
        
    } else {
        echo '<div class="error">✗ Database connection failed!</div>';
        echo '<h3>Troubleshooting Steps:</h3>';
        echo '<ol>';
        echo '<li>Make sure MySQL is running in XAMPP/WAMP</li>';
        echo '<li>Check database credentials in config/database.php</li>';
        echo '<li>Import database/schema.sql in phpMyAdmin</li>';
        echo '<li>Verify database name is "smart_parking_db"</li>';
        echo '</ol>';
    }
    ?>
    
    <hr style="margin: 30px 0;">
    
    <h3>PHP Information:</h3>
    <p><strong>PHP Version:</strong> <?php echo phpversion(); ?></p>
    <p><strong>MySQL Extension:</strong> <?php echo extension_loaded('mysqli') ? '✓ Loaded' : '✗ Not Loaded'; ?></p>
    
</div>

</body>
</html>
