<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

session_start();

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'create':
        createBooking();
        break;
    case 'getMyBookings':
        getMyBookings();
        break;
    case 'getAllBookings':
        getAllBookings();
        break;
    case 'cancel':
        cancelBooking();
        break;
    case 'processExit':
        processExit();
        break;
    case 'getActive':
        getActiveBookings();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
}

function createBooking() {
    if (!isset($_SESSION['user_id'])) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    $slotId = $data['slot_id'] ?? 0;
    $vehicleNumber = $data['vehicle_number'] ?? '';
    $vehicleType = $data['vehicle_type'] ?? 'car';
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    // Check if slot is available
    $slotQuery = "SELECT status FROM parking_slots WHERE id = ?";
    $slot = fetchOne($conn, $slotQuery, [$slotId], 'i');
    
    if (!$slot || $slot['status'] !== 'available') {
        echo json_encode(['success' => false, 'message' => 'Slot not available']);
        closeDBConnection($conn);
        return;
    }
    
    // Create booking
    $bookingQuery = "INSERT INTO bookings (user_id, slot_id, vehicle_number, vehicle_type, status) VALUES (?, ?, ?, ?, 'active')";
    $stmt = executeQuery($conn, $bookingQuery, [$_SESSION['user_id'], $slotId, $vehicleNumber, $vehicleType], 'iiss');
    
    if ($stmt) {
        // Update slot status
        $updateQuery = "UPDATE parking_slots SET status = 'reserved' WHERE id = ?";
        executeQuery($conn, $updateQuery, [$slotId], 'i');
        
        // Log activity
        $logQuery = "INSERT INTO activity_logs (user_id, action, description) VALUES (?, 'create_booking', ?)";
        $description = "Booked slot for vehicle $vehicleNumber";
        executeQuery($conn, $logQuery, [$_SESSION['user_id'], $description], 'is');
        
        echo json_encode(['success' => true, 'message' => 'Booking created successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Booking failed']);
    }
    
    closeDBConnection($conn);
}

function getMyBookings() {
    if (!isset($_SESSION['user_id'])) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT b.*, p.slot_number, p.floor_number 
              FROM bookings b 
              JOIN parking_slots p ON b.slot_id = p.id 
              WHERE b.user_id = ? 
              ORDER BY b.booking_date DESC";
    $bookings = fetchAll($conn, $query, [$_SESSION['user_id']], 'i');
    
    echo json_encode(['success' => true, 'bookings' => $bookings]);
    closeDBConnection($conn);
}

function getAllBookings() {
    if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT b.*, u.username, u.fullname, p.slot_number, p.floor_number 
              FROM bookings b 
              JOIN users u ON b.user_id = u.id 
              JOIN parking_slots p ON b.slot_id = p.id 
              ORDER BY b.booking_date DESC";
    $bookings = fetchAll($conn, $query);
    
    echo json_encode(['success' => true, 'bookings' => $bookings]);
    closeDBConnection($conn);
}

function cancelBooking() {
    if (!isset($_SESSION['user_id'])) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    $bookingId = $data['booking_id'] ?? 0;
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    // Get booking details
    $bookingQuery = "SELECT * FROM bookings WHERE id = ? AND user_id = ? AND status = 'active'";
    $booking = fetchOne($conn, $bookingQuery, [$bookingId, $_SESSION['user_id']], 'ii');
    
    if (!$booking) {
        echo json_encode(['success' => false, 'message' => 'Booking not found or cannot be cancelled']);
        closeDBConnection($conn);
        return;
    }
    
    // Cancel booking
    $cancelQuery = "UPDATE bookings SET status = 'cancelled' WHERE id = ?";
    $stmt = executeQuery($conn, $cancelQuery, [$bookingId], 'i');
    
    if ($stmt) {
        // Update slot status
        $updateQuery = "UPDATE parking_slots SET status = 'available' WHERE id = ?";
        executeQuery($conn, $updateQuery, [$booking['slot_id']], 'i');
        
        // Log activity
        $logQuery = "INSERT INTO activity_logs (user_id, action, description) VALUES (?, 'cancel_booking', 'Cancelled booking')";
        executeQuery($conn, $logQuery, [$_SESSION['user_id'], 'is']);
        
        echo json_encode(['success' => true, 'message' => 'Booking cancelled successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Cancellation failed']);
    }
    
    closeDBConnection($conn);
}

function processExit() {
    if (!isset($_SESSION['user_id']) || !in_array($_SESSION['role'], ['security', 'admin'])) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    $bookingId = $data['booking_id'] ?? 0;
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    // Get booking details
    $bookingQuery = "SELECT * FROM bookings WHERE id = ? AND status = 'active'";
    $booking = fetchOne($conn, $bookingQuery, [$bookingId], 'i');
    
    if (!$booking) {
        echo json_encode(['success' => false, 'message' => 'Booking not found']);
        closeDBConnection($conn);
        return;
    }
    
    // Calculate amount (₹20 per hour)
    $entryTime = strtotime($booking['booking_date']);
    $exitTime = time();
    $hours = ceil(($exitTime - $entryTime) / 3600);
    $amount = $hours * 20;
    
    // Update booking
    $updateQuery = "UPDATE bookings SET status = 'completed', exit_time = NOW(), amount = ? WHERE id = ?";
    $stmt = executeQuery($conn, $updateQuery, [$amount, $bookingId], 'di');
    
    if ($stmt) {
        // Update slot status
        $slotQuery = "UPDATE parking_slots SET status = 'available' WHERE id = ?";
        executeQuery($conn, $slotQuery, [$booking['slot_id']], 'i');
        
        // Log activity
        $logQuery = "INSERT INTO activity_logs (user_id, action, description) VALUES (?, 'process_exit', ?)";
        $description = "Processed exit for booking #$bookingId, Amount: ₹$amount";
        executeQuery($conn, $logQuery, [$_SESSION['user_id'], $description], 'is');
        
        echo json_encode(['success' => true, 'message' => 'Exit processed successfully', 'amount' => $amount]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Exit processing failed']);
    }
    
    closeDBConnection($conn);
}

function getActiveBookings() {
    if (!isset($_SESSION['user_id']) || !in_array($_SESSION['role'], ['security', 'admin'])) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        return;
    }
    
    $conn = getDBConnection();
    if (!$conn) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        return;
    }
    
    $query = "SELECT b.*, u.username, u.fullname, p.slot_number 
              FROM bookings b 
              JOIN users u ON b.user_id = u.id 
              JOIN parking_slots p ON b.slot_id = p.id 
              WHERE b.status = 'active' 
              ORDER BY b.booking_date DESC";
    $bookings = fetchAll($conn, $query);
    
    echo json_encode(['success' => true, 'bookings' => $bookings]);
    closeDBConnection($conn);
}
?>
