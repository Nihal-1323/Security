// Check if user is logged in
function checkAuth() {
    const user = JSON.parse(localStorage.getItem('currentUser'));
    if (!user) {
        window.location.href = 'login.html';
        return null;
    }
    return user;
}

// Logout function
async function logout() {
    if (confirm('Are you sure you want to logout?')) {
        try {
            await fetch('api/auth.php?action=logout');
        } catch (error) {
            console.error('Logout error:', error);
        }
        localStorage.removeItem('currentUser');
        window.location.href = 'index.html';
    }
}

// API Helper Functions
async function apiCall(endpoint, method = 'GET', data = null) {
    try {
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json'
            }
        };
        
        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }
        
        const response = await fetch(endpoint, options);
        return await response.json();
    } catch (error) {
        console.error('API call error:', error);
        return { success: false, message: 'Connection error' };
    }
}

// Navigation items based on role
const navigationItems = {
    admin: [
        { icon: '📊', label: 'Dashboard', view: 'dashboard' },
        { icon: '🚗', label: 'Parking Slots', view: 'slots' },
        { icon: '👥', label: 'Users', view: 'users' },
        { icon: '📋', label: 'Bookings', view: 'bookings' }
    ],
    security: [
        { icon: '📊', label: 'Dashboard', view: 'dashboard' },
        { icon: '🚗', label: 'Parking Slots', view: 'slots' },
        { icon: '🚪', label: 'Entry/Exit', view: 'entry-exit' }
    ],
    user: [
        { icon: '📊', label: 'Dashboard', view: 'dashboard' },
        { icon: '🚗', label: 'Available Slots', view: 'available' },
        { icon: '📝', label: 'My Bookings', view: 'my-bookings' }
    ]
};

// Render sidebar navigation
function renderNavigation(role) {
    const nav = document.getElementById('sidebarNav');
    const items = navigationItems[role] || [];
    
    nav.innerHTML = items.map((item, index) => `
        <div class="nav-item ${index === 0 ? 'active' : ''}" onclick="loadView('${item.view}')">
            <span>${item.icon}</span>
            <span>${item.label}</span>
        </div>
    `).join('');
}

// Load view based on selection
function loadView(view) {
    const user = checkAuth();
    if (!user) return;
    
    // Update active nav item
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.remove('active');
    });
    if (event && event.target) {
        event.target.closest('.nav-item').classList.add('active');
    }
    
    switch(view) {
        case 'dashboard':
            renderDashboard(user);
            break;
        case 'slots':
            renderSlots(user);
            break;
        case 'available':
            renderAvailableSlots(user);
            break;
        case 'my-bookings':
            renderMyBookings(user);
            break;
        case 'users':
            renderUsers();
            break;
        case 'bookings':
            renderAllBookings();
            break;
        case 'entry-exit':
            renderEntryExit();
            break;
        default:
            renderDashboard(user);
    }
}

// Render dashboard
async function renderDashboard(user) {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<p>Loading...</p>';
    
    const statsData = await apiCall('api/slots.php?action=getStats');
    const stats = statsData.stats || {};
    
    const available = stats.available || 0;
    const occupied = stats.occupied || 0;
    const reserved = stats.reserved || 0;
    
    let userBookingsCount = 0;
    if (user.role === 'user') {
        const bookingsData = await apiCall('api/bookings.php?action=getMyBookings');
        userBookingsCount = bookingsData.bookings ? bookingsData.bookings.length : 0;
    }
    
    const slotsData = await apiCall('api/slots.php?action=getAll');
    const slots = slotsData.slots || [];
    
    content.innerHTML = `
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Available Slots</h3>
                <div class="value">${available}</div>
            </div>
            <div class="stat-card">
                <h3>Occupied Slots</h3>
                <div class="value">${occupied}</div>
            </div>
            <div class="stat-card">
                <h3>Reserved Slots</h3>
                <div class="value">${reserved}</div>
            </div>
            ${user.role === 'user' ? `
            <div class="stat-card">
                <h3>My Bookings</h3>
                <div class="value">${userBookingsCount}</div>
            </div>
            ` : ''}
        </div>
        
        <h2 style="margin: 2rem 0 1rem;">Parking Overview</h2>
        <div class="parking-grid">
            ${slots.map(slot => `
                <div class="parking-slot ${slot.status}">
                    ${slot.slot_number}
                </div>
            `).join('')}
        </div>
    `;
}

// Render all slots
async function renderSlots(user) {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<p>Loading...</p>';
    
    const data = await apiCall('api/slots.php?action=getAll');
    const slots = data.slots || [];
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Parking Slots Management</h2>
        <div class="parking-grid">
            ${slots.map(slot => `
                <div class="parking-slot ${slot.status}">
                    ${slot.slot_number}
                </div>
            `).join('')}
        </div>
    `;
}

// Render available slots for booking
async function renderAvailableSlots(user) {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<p>Loading...</p>';
    
    const data = await apiCall('api/slots.php?action=getAvailable');
    const available = data.slots || [];
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Available Parking Slots</h2>
        <div class="parking-grid">
            ${available.map(slot => `
                <div class="parking-slot available" onclick="bookSlot(${slot.id}, '${slot.slot_number}')">
                    ${slot.slot_number}
                </div>
            `).join('')}
        </div>
        ${available.length === 0 ? '<p style="text-align: center; color: #666;">No slots available at the moment.</p>' : ''}
    `;
}

// Book a slot
async function bookSlot(slotId, slotNumber) {
    const vehicleNumber = prompt(`Enter vehicle number for slot ${slotNumber}:`);
    if (!vehicleNumber) return;
    
    const vehicleType = prompt('Enter vehicle type (car/bike/truck):', 'car');
    if (!vehicleType) return;
    
    const data = await apiCall('api/bookings.php?action=create', 'POST', {
        slot_id: slotId,
        vehicle_number: vehicleNumber,
        vehicle_type: vehicleType
    });
    
    if (data.success) {
        alert('Slot booked successfully!');
        loadView('my-bookings');
    } else {
        alert(data.message || 'Booking failed');
    }
}

// Render user's bookings
async function renderMyBookings(user) {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<p>Loading...</p>';
    
    const data = await apiCall('api/bookings.php?action=getMyBookings');
    const bookings = data.bookings || [];
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">My Bookings</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Slot Number</th>
                        <th>Vehicle</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Amount</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    ${bookings.length > 0 ? bookings.map(booking => `
                        <tr>
                            <td>${booking.slot_number}</td>
                            <td>${booking.vehicle_number || 'N/A'}</td>
                            <td>${new Date(booking.booking_date).toLocaleString()}</td>
                            <td><span class="status-badge ${booking.status}">${booking.status}</span></td>
                            <td>₹${parseFloat(booking.amount).toFixed(2)}</td>
                            <td>
                                ${booking.status === 'active' ? 
                                    `<button class="btn-secondary" onclick="cancelBooking(${booking.id})">Cancel</button>` : 
                                    '-'}
                            </td>
                        </tr>
                    `).join('') : '<tr><td colspan="6" style="text-align: center;">No bookings found</td></tr>'}
                </tbody>
            </table>
        </div>
    `;
}

// Cancel booking
async function cancelBooking(bookingId) {
    if (!confirm('Are you sure you want to cancel this booking?')) return;
    
    const data = await apiCall('api/bookings.php?action=cancel', 'POST', { booking_id: bookingId });
    
    if (data.success) {
        alert('Booking cancelled successfully!');
        loadView('my-bookings');
    } else {
        alert(data.message || 'Cancellation failed');
    }
}

// Render users (admin only)
async function renderUsers() {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<p>Loading...</p>';
    
    const data = await apiCall('api/users.php?action=getAll');
    const users = data.users || [];
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Registered Users</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Full Name</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Role</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    ${users.map(user => `
                        <tr>
                            <td>${user.fullname}</td>
                            <td>${user.username}</td>
                            <td>${user.email}</td>
                            <td>${user.phone || 'N/A'}</td>
                            <td><span class="status-badge active">${user.role}</span></td>
                            <td><span class="status-badge ${user.status}">${user.status}</span></td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        </div>
    `;
}

// Render all bookings (admin only)
async function renderAllBookings() {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<p>Loading...</p>';
    
    const data = await apiCall('api/bookings.php?action=getAllBookings');
    const bookings = data.bookings || [];
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">All Bookings</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Slot</th>
                        <th>User</th>
                        <th>Vehicle</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
                    ${bookings.length > 0 ? bookings.map(booking => `
                        <tr>
                            <td>${booking.slot_number}</td>
                            <td>${booking.fullname}</td>
                            <td>${booking.vehicle_number || 'N/A'}</td>
                            <td>${new Date(booking.booking_date).toLocaleString()}</td>
                            <td><span class="status-badge ${booking.status}">${booking.status}</span></td>
                            <td>₹${parseFloat(booking.amount).toFixed(2)}</td>
                        </tr>
                    `).join('') : '<tr><td colspan="6" style="text-align: center;">No bookings found</td></tr>'}
                </tbody>
            </table>
        </div>
    `;
}

// Render entry/exit (security only)
async function renderEntryExit() {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<p>Loading...</p>';
    
    const data = await apiCall('api/bookings.php?action=getActive');
    const bookings = data.bookings || [];
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Vehicle Entry/Exit Management</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Slot</th>
                        <th>User</th>
                        <th>Vehicle</th>
                        <th>Booking Time</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    ${bookings.length > 0 ? bookings.map(booking => `
                        <tr>
                            <td>${booking.slot_number}</td>
                            <td>${booking.fullname}</td>
                            <td>${booking.vehicle_number || 'N/A'}</td>
                            <td>${new Date(booking.booking_date).toLocaleString()}</td>
                            <td>
                                <button class="btn-primary" onclick="processExit(${booking.id})">Process Exit</button>
                            </td>
                        </tr>
                    `).join('') : '<tr><td colspan="5" style="text-align: center;">No active bookings</td></tr>'}
                </tbody>
            </table>
        </div>
    `;
}

// Process exit
async function processExit(bookingId) {
    if (!confirm('Process vehicle exit?')) return;
    
    const data = await apiCall('api/bookings.php?action=processExit', 'POST', { booking_id: bookingId });
    
    if (data.success) {
        alert(`Exit processed successfully! Amount: ₹${data.amount}`);
        loadView('entry-exit');
    } else {
        alert(data.message || 'Exit processing failed');
    }
}

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    const user = checkAuth();
    if (!user) return;
    
    // Set welcome message
    document.getElementById('welcomeMessage').textContent = `Welcome, ${user.fullname || user.username}`;
    document.getElementById('userInfo').textContent = `Role: ${user.role.charAt(0).toUpperCase() + user.role.slice(1)}`;
    
    // Render navigation
    renderNavigation(user.role);
    
    // Load default view
    renderDashboard(user);
});
