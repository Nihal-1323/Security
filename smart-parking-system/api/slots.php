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
        getAllSlots();
        break;
    case 'getAvailable':
        getAvailableSlots();
        break;
    case 'getById':
        getSlotById();
        break;
    case 'updateStatus':
        updateSlotStatus();
        break;
    case 'getStats':
        getSlotStats();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
}

function getAllSlots() {
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT * FROM parking_slots ORDER BY slot_number";
    $slots = fetchAll($conn, $query);
    
    echo json_encode(['success' => true, 'slots' => $slots]);
    closeDBConnection($conn);
}

function getAvailableSlots() {
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT * FROM parking_slots WHERE status = 'available' ORDER BY slot_number";
    $slots = fetchAll($conn, $query);
    
    echo json_encode(['success' => true, 'slots' => $slots]);
    closeDBConnection($conn);
}

function getSlotById() {
    $id = $_GET['id'] ?? 0;
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT * FROM parking_slots WHERE id = ?";
    $slot = fetchOne($conn, $query, [$id], 'i');
    
    if ($slot) {
        echo json_encode(['success' => true, 'slot' => $slot]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Slot not found']);
    }
    
    closeDBConnection($conn);
}

function updateSlotStatus() {
    if (!isset($_SESSION['user_id'])) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    $slotId = $data['slot_id'] ?? 0;
    $status = $data['status'] ?? '';
    
    if (!in_array($status, ['available', 'occupied', 'reserved', 'maintenance'])) {
        echo json_encode(['success' => false, 'message' => 'Invalid status']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "UPDATE parking_slots SET status = ? WHERE id = ?";
    $stmt = executeQuery($conn, $query, [$status, $slotId], 'si');
    
    if ($stmt) {
        // Log activity
        $logQuery = "INSERT INTO activity_logs (user_id, action, description) VALUES (?, 'update_slot', ?)";
        $description = "Updated slot status to $status";
        executeQuery($conn, $logQuery, [$_SESSION['user_id'], $description], 'is');
        
        echo json_encode(['success' => true, 'message' => 'Slot status updated']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Update failed']);
    }
    
    closeDBConnection($conn);
}

function getSlotStats() {
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $stats = [];
    
    // Count by status
    $query = "SELECT status, COUNT(*) as count FROM parking_slots GROUP BY status";
    $results = fetchAll($conn, $query);
    
    foreach ($results as $row) {
        $stats[$row['status']] = (int)$row['count'];
    }
    
    // Total slots
    $totalQuery = "SELECT COUNT(*) as total FROM parking_slots";
    $total = fetchOne($conn, $totalQuery);
    $stats['total'] = (int)$total['total'];
    
    echo json_encode(['success' => true, 'stats' => $stats]);
    closeDBConnection($conn);
}
?>
