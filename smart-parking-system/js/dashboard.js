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
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('currentUser');
        window.location.href = 'index.html';
    }
}

// Load parking slots
function loadParkingSlots() {
    const saved = localStorage.getItem('parkingSlots');
    if (saved) {
        return JSON.parse(saved);
    }
    return [];
}

// Save parking slots
function saveParkingSlots(slots) {
    localStorage.setItem('parkingSlots', JSON.stringify(slots));
}

// Get bookings
function getBookings() {
    return JSON.parse(localStorage.getItem('bookings') || '[]');
}

// Save bookings
function saveBookings(bookings) {
    localStorage.setItem('bookings', JSON.stringify(bookings));
}

// Navigation items based on role
const navigationItems = {
    admin: [
        { icon: '📊', label: 'Dashboard', view: 'dashboard' },
        { icon: '🚗', label: 'Parking Slots', view: 'slots' },
        { icon: '👥', label: 'Users', view: 'users' },
        { icon: '📋', label: 'Bookings', view: 'bookings' },
        { icon: '💰', label: 'Revenue', view: 'revenue' }
    ],
    security: [
        { icon: '📊', label: 'Dashboard', view: 'dashboard' },
        { icon: '🚗', label: 'Parking Slots', view: 'slots' },
        { icon: '🚪', label: 'Entry/Exit', view: 'entry-exit' },
        { icon: '📋', label: 'Activity Log', view: 'logs' }
    ],
    user: [
        { icon: '📊', label: 'Dashboard', view: 'dashboard' },
        { icon: '🚗', label: 'Available Slots', view: 'available' },
        { icon: '📝', label: 'My Bookings', view: 'my-bookings' },
        { icon: '💳', label: 'Payments', view: 'payments' },
        { icon: '📞', label: 'Support', view: 'support' }
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
    event.target.closest('.nav-item').classList.add('active');
    
    const content = document.getElementById('dashboardContent');
    
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
function renderDashboard(user) {
    const slots = loadParkingSlots();
    const bookings = getBookings();
    const userBookings = bookings.filter(b => b.username === user.username);
    
    const available = slots.filter(s => s.status === 'available').length;
    const occupied = slots.filter(s => s.status === 'occupied').length;
    const reserved = slots.filter(s => s.status === 'reserved').length;
    
    const content = document.getElementById('dashboardContent');
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
                <div class="value">${userBookings.length}</div>
            </div>
            ` : ''}
        </div>
        
        <h2 style="margin: 2rem 0 1rem;">Parking Overview</h2>
        <div class="parking-grid">
            ${slots.map(slot => `
                <div class="parking-slot ${slot.status}">
                    ${slot.number}
                </div>
            `).join('')}
        </div>
    `;
}

// Render all slots
function renderSlots(user) {
    const slots = loadParkingSlots();
    const content = document.getElementById('dashboardContent');
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Parking Slots Management</h2>
        <div class="parking-grid">
            ${slots.map(slot => `
                <div class="parking-slot ${slot.status}" onclick="manageSlot(${slot.id})">
                    ${slot.number}
                </div>
            `).join('')}
        </div>
    `;
}

// Render available slots for booking
function renderAvailableSlots(user) {
    const slots = loadParkingSlots();
    const available = slots.filter(s => s.status === 'available');
    const content = document.getElementById('dashboardContent');
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Available Parking Slots</h2>
        <div class="parking-grid">
            ${available.map(slot => `
                <div class="parking-slot available" onclick="bookSlot(${slot.id}, '${user.username}')">
                    ${slot.number}
                </div>
            `).join('')}
        </div>
        ${available.length === 0 ? '<p style="text-align: center; color: #666;">No slots available at the moment.</p>' : ''}
    `;
}

// Book a slot
function bookSlot(slotId, username) {
    if (!confirm('Do you want to book this slot?')) return;
    
    const slots = loadParkingSlots();
    const slot = slots.find(s => s.id === slotId);
    
    if (slot && slot.status === 'available') {
        slot.status = 'reserved';
        saveParkingSlots(slots);
        
        const bookings = getBookings();
        bookings.push({
            id: Date.now(),
            slotId: slot.id,
            slotNumber: slot.number,
            username: username,
            date: new Date().toISOString(),
            status: 'active'
        });
        saveBookings(bookings);
        
        alert('Slot booked successfully!');
        loadView('my-bookings');
    }
}

// Render user's bookings
function renderMyBookings(user) {
    const bookings = getBookings().filter(b => b.username === user.username);
    const content = document.getElementById('dashboardContent');
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">My Bookings</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Slot Number</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    ${bookings.length > 0 ? bookings.map(booking => `
                        <tr>
                            <td>${booking.slotNumber}</td>
                            <td>${new Date(booking.date).toLocaleString()}</td>
                            <td><span class="status-badge ${booking.status}">${booking.status}</span></td>
                            <td>
                                ${booking.status === 'active' ? 
                                    `<button class="btn-secondary" onclick="cancelBooking(${booking.id})">Cancel</button>` : 
                                    '-'}
                            </td>
                        </tr>
                    `).join('') : '<tr><td colspan="4" style="text-align: center;">No bookings found</td></tr>'}
                </tbody>
            </table>
        </div>
    `;
}

// Cancel booking
function cancelBooking(bookingId) {
    if (!confirm('Are you sure you want to cancel this booking?')) return;
    
    const bookings = getBookings();
    const booking = bookings.find(b => b.id === bookingId);
    
    if (booking) {
        // Update slot status
        const slots = loadParkingSlots();
        const slot = slots.find(s => s.id === booking.slotId);
        if (slot) {
            slot.status = 'available';
            saveParkingSlots(slots);
        }
        
        // Update booking status
        booking.status = 'cancelled';
        saveBookings(bookings);
        
        alert('Booking cancelled successfully!');
        loadView('my-bookings');
    }
}

// Render users (admin only)
function renderUsers() {
    const users = JSON.parse(localStorage.getItem('users') || '[]');
    const content = document.getElementById('dashboardContent');
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Registered Users</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Full Name</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Role</th>
                    </tr>
                </thead>
                <tbody>
                    ${users.map(user => `
                        <tr>
                            <td>${user.fullname}</td>
                            <td>${user.username}</td>
                            <td>${user.email}</td>
                            <td><span class="status-badge active">${user.role}</span></td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        </div>
    `;
}

// Render all bookings (admin only)
function renderAllBookings() {
    const bookings = getBookings();
    const content = document.getElementById('dashboardContent');
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">All Bookings</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Slot Number</th>
                        <th>User</th>
                        <th>Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    ${bookings.length > 0 ? bookings.map(booking => `
                        <tr>
                            <td>${booking.slotNumber}</td>
                            <td>${booking.username}</td>
                            <td>${new Date(booking.date).toLocaleString()}</td>
                            <td><span class="status-badge ${booking.status}">${booking.status}</span></td>
                        </tr>
                    `).join('') : '<tr><td colspan="4" style="text-align: center;">No bookings found</td></tr>'}
                </tbody>
            </table>
        </div>
    `;
}

// Render entry/exit (security only)
function renderEntryExit() {
    const bookings = getBookings().filter(b => b.status === 'active');
    const content = document.getElementById('dashboardContent');
    
    content.innerHTML = `
        <h2 style="margin-bottom: 2rem;">Vehicle Entry/Exit Management</h2>
        <div class="data-table">
            <table>
                <thead>
                    <tr>
                        <th>Slot Number</th>
                        <th>User</th>
                        <th>Booking Time</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    ${bookings.length > 0 ? bookings.map(booking => `
                        <tr>
                            <td>${booking.slotNumber}</td>
                            <td>${booking.username}</td>
                            <td>${new Date(booking.date).toLocaleString()}</td>
                            <td>
                                <button class="btn-primary" onclick="processExit(${booking.id})">Process Exit</button>
                            </td>
                        </tr>
                    `).join('') : '<tr><td colspan="4" style="text-align: center;">No active bookings</td></tr>'}
                </tbody>
            </table>
        </div>
    `;
}

// Process exit
function processExit(bookingId) {
    if (!confirm('Process vehicle exit?')) return;
    
    const bookings = getBookings();
    const booking = bookings.find(b => b.id === bookingId);
    
    if (booking) {
        // Update slot status
        const slots = loadParkingSlots();
        const slot = slots.find(s => s.id === booking.slotId);
        if (slot) {
            slot.status = 'available';
            saveParkingSlots(slots);
        }
        
        // Update booking status
        booking.status = 'completed';
        booking.exitTime = new Date().toISOString();
        saveBookings(bookings);
        
        alert('Exit processed successfully!');
        loadView('entry-exit');
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
