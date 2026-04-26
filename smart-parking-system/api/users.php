<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

session_start();

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'getAll':
        getAllUsers();
        break;
    case 'getStats':
        getUserStats();
        break;
    case 'updateStatus':
        updateUserStatus();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
}

function getAllUsers() {
    if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT id, fullname, username, email, phone, role, status, created_at FROM users ORDER BY created_at DESC";
    $users = fetchAll($conn, $query);
    
    echo json_encode(['success' => true, 'users' => $users]);
    closeDBConnection($conn);
}

function getUserStats() {
    if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $stats = [];
    
    // Total users
    $totalQuery = "SELECT COUNT(*) as total FROM users WHERE role = 'user'";
    $total = fetchOne($conn, $totalQuery);
    $stats['total_users'] = (int)$total['total'];
    
    // Active users
    $activeQuery = "SELECT COUNT(*) as active FROM users WHERE status = 'active'";
    $active = fetchOne($conn, $activeQuery);
    $stats['active_users'] = (int)$active['active'];
    
    // Users by role
    $roleQuery = "SELECT role, COUNT(*) as count FROM users GROUP BY role";
    $roles = fetchAll($conn, $roleQuery);
    foreach ($roles as $role) {
        $stats['by_role'][$role['role']] = (int)$role['count'];
    }
    
    echo json_encode(['success' => true, 'stats' => $stats]);
    closeDBConnection($conn);
}

function updateUserStatus() {
    if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'] ?? 0;
    $status = $data['status'] ?? '';
    
    if (!in_array($status, ['active', 'inactive'])) {
        echo json_encode(['success' => false, 'message' => 'Invalid status']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "UPDATE users SET status = ? WHERE id = ?";
    $stmt = executeQuery($conn, $query, [$status, $userId], 'si');
    
    if ($stmt) {
        echo json_encode(['success' => true, 'message' => 'User status updated']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Update failed']);
    }
    
    closeDBConnection($conn);
}
?>
