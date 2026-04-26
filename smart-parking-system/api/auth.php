<?php
// Enable error reporting for debugging (remove in production)
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't display errors in output
ini_set('log_errors', 1);

// Set headers before any output
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Start session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Include database config
require_once '../config/database.php';

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'login':
        handleLogin();
        break;
    case 'register':
        handleRegister();
        break;
    case 'logout':
        handleLogout();
        break;
    case 'check':
        checkSession();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
}

function handleLogin() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $username = $data['username'] ?? '';
    $password = $data['password'] ?? '';
    $role = $data['role'] ?? '';
    
    if (empty($username) || empty($password) || empty($role)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT * FROM users WHERE username = ? AND role = ? AND status = 'active'";
    $user = fetchOne($conn, $query, [$username, $role], 'ss');
    
    if ($user && password_verify($password, $user['password'])) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['username'] = $user['username'];
        $_SESSION['fullname'] = $user['fullname'];
        $_SESSION['role'] = $user['role'];
        
        // Log activity
        $logQuery = "INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES (?, 'login', 'User logged in', ?)";
        executeQuery($conn, $logQuery, [$user['id'], $_SERVER['REMOTE_ADDR']], 'is');
        
        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $user['id'],
                'username' => $user['username'],
                'fullname' => $user['fullname'],
                'email' => $user['email'],
                'role' => $user['role']
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
    }
    
    closeDBConnection($conn);
}

function handleRegister() {
    try {
        // Get and decode JSON input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        // Check if JSON decode was successful
        if (json_last_error() !== JSON_ERROR_NONE) {
            echo json_encode(['success' => false, 'message' => 'Invalid JSON data']);
            return;
        }
        
        $fullname = $data['fullname'] ?? '';
        $username = $data['username'] ?? '';
        $email = $data['email'] ?? '';
        $phone = $data['phone'] ?? '';
        $password = $data['password'] ?? '';
        $role = $data['role'] ?? 'user';
        
        // Validate required fields
        if (empty($fullname) || empty($username) || empty($email) || empty($password)) {
            echo json_encode(['success' => false, 'message' => 'All required fields must be filled']);
            return;
        }
        
        // Validate password length
        if (strlen($password) < 6) {
            echo json_encode(['success' => false, 'message' => 'Password must be at least 6 characters']);
            return;
        }
        
        // Get database connection
        $conn = getDBConnection();
        if (!$conn) {
            echo json_encode(['success' => false, 'message' => 'Database connection failed']);
            return;
        }
        
        // Check if username or email already exists
        $checkQuery = "SELECT id FROM users WHERE username = ? OR email = ?";
        $existing = fetchOne($conn, $checkQuery, [$username, $email], 'ss');
        
        if ($existing) {
            echo json_encode(['success' => false, 'message' => 'Username or email already exists']);
            closeDBConnection($conn);
            return;
        }
        
        // Hash password
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        
        // Insert new user
        $insertQuery = "INSERT INTO users (fullname, username, email, phone, password, role) VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = executeQuery($conn, $insertQuery, [$fullname, $username, $email, $phone, $hashedPassword, $role], 'ssssss');
        
        if ($stmt) {
            echo json_encode(['success' => true, 'message' => 'Registration successful']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Registration failed. Please try again.']);
        }
        
        closeDBConnection($conn);
        
    } catch (Exception $e) {
        error_log("Registration error: " . $e->getMessage());
        echo json_encode(['success' => false, 'message' => 'An error occurred during registration']);
    }
}

function handleLogout() {
    if (isset($_SESSION['user_id'])) {
        $conn = getDBConnection();
        if ($conn) {
            $logQuery = "INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES (?, 'logout', 'User logged out', ?)";
            executeQuery($conn, $logQuery, [$_SESSION['user_id'], $_SERVER['REMOTE_ADDR']], 'is');
            closeDBConnection($conn);
        }
    }
    
    session_destroy();
    echo json_encode(['success' => true, 'message' => 'Logged out successfully']);
}

function checkSession() {
    if (isset($_SESSION['user_id'])) {
        $conn = getDBConnection();
        if ($conn) {
            $query = "SELECT id, username, fullname, email, role FROM users WHERE id = ? AND status = 'active'";
            $user = fetchOne($conn, $query, [$_SESSION['user_id']], 'i');
            closeDBConnection($conn);
            
            if ($user) {
                echo json_encode(['success' => true, 'user' => $user]);
                return;
            }
        }
    }
    echo json_encode(['success' => false, 'message' => 'Not authenticated']);
}
?>
