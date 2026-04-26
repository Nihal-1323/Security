<?php
// Direct registration test with error display
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h2>Testing Registration API Directly</h2>";

// Test 1: Check if database config exists
echo "<h3>Test 1: Database Config</h3>";
if (file_exists('config/database.php')) {
    echo "✓ config/database.php exists<br>";
    require_once 'config/database.php';
    echo "✓ config/database.php loaded<br>";
} else {
    echo "✗ config/database.php NOT FOUND<br>";
    exit;
}

// Test 2: Check database connection
echo "<h3>Test 2: Database Connection</h3>";
$conn = getDBConnection();
if ($conn) {
    echo "✓ Database connection successful<br>";
} else {
    echo "✗ Database connection FAILED<br>";
    exit;
}

// Test 3: Check if users table exists
echo "<h3>Test 3: Users Table</h3>";
$result = $conn->query("SHOW TABLES LIKE 'users'");
if ($result && $result->num_rows > 0) {
    echo "✓ Users table exists<br>";
} else {
    echo "✗ Users table NOT FOUND<br>";
    exit;
}

// Test 4: Try to insert a test user
echo "<h3>Test 4: Test Registration</h3>";
$testUsername = 'testuser_' . time();
$testEmail = 'test_' . time() . '@test.com';
$testPassword = password_hash('test123', PASSWORD_DEFAULT);

$query = "INSERT INTO users (fullname, username, email, phone, password, role) VALUES (?, ?, ?, ?, ?, ?)";
$stmt = $conn->prepare($query);

if (!$stmt) {
    echo "✗ Prepare failed: " . $conn->error . "<br>";
    exit;
}

$fullname = "Test User";
$phone = "1234567890";
$role = "user";

$stmt->bind_param('ssssss', $fullname, $testUsername, $testEmail, $phone, $testPassword, $role);

if ($stmt->execute()) {
    echo "✓ Test user created successfully<br>";
    echo "Username: $testUsername<br>";
    echo "Email: $testEmail<br>";
    
    // Clean up test user
    $deleteQuery = "DELETE FROM users WHERE username = ?";
    $deleteStmt = $conn->prepare($deleteQuery);
    $deleteStmt->bind_param('s', $testUsername);
    $deleteStmt->execute();
    echo "✓ Test user cleaned up<br>";
} else {
    echo "✗ Insert failed: " . $stmt->error . "<br>";
}

// Test 5: Test the actual API endpoint
echo "<h3>Test 5: API Endpoint Test</h3>";
echo "<p>Open browser console and click the button below:</p>";
?>

<button onclick="testAPI()">Test Registration API</button>
<div id="apiResult" style="margin-top: 10px; padding: 10px; border: 1px solid #ccc;"></div>

<script>
async function testAPI() {
    const resultDiv = document.getElementById('apiResult');
    resultDiv.innerHTML = 'Testing...';
    
    try {
        const testData = {
            fullname: 'API Test User',
            email: 'apitest_' + Date.now() + '@test.com',
            phone: '9876543210',
            username: 'apitest_' + Date.now(),
            password: 'test123',
            role: 'user'
        };
        
        console.log('Sending request:', testData);
        
        const response = await fetch('api/auth.php?action=register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(testData)
        });
        
        console.log('Response status:', response.status);
        console.log('Response headers:', response.headers);
        
        const text = await response.text();
        console.log('Response text:', text);
        
        try {
            const data = JSON.parse(text);
            resultDiv.innerHTML = '<strong>Success!</strong><br>' + JSON.stringify(data, null, 2);
            resultDiv.style.background = '#d4edda';
        } catch (e) {
            resultDiv.innerHTML = '<strong>JSON Parse Error:</strong><br>' + text;
            resultDiv.style.background = '#f8d7da';
        }
        
    } catch (error) {
        console.error('Fetch error:', error);
        resultDiv.innerHTML = '<strong>Error:</strong><br>' + error.message;
        resultDiv.style.background = '#f8d7da';
    }
}
</script>

<?php
closeDBConnection($conn);
echo "<h3>All Tests Complete</h3>";
echo "<p>If all tests pass, the registration should work. Check browser console (F12) for detailed API test results.</p>";
?>
