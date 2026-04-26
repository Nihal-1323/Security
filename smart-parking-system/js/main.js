// Initialize parking slots
async function loadParkingSlotsFromDB() {
    try {
        const response = await fetch('api/slots.php?action=getAll');
        const data = await response.json();
        if (data.success) {
            return data.slots;
        }
    } catch (error) {
        console.error('Error loading slots:', error);
    }
    return [];
}

// Render parking slots
async function renderParkingSlots() {
    const grid = document.getElementById('parkingGrid');
    if (!grid) return;
    
    const slots = await loadParkingSlotsFromDB();
    grid.innerHTML = '';
    
    if (slots.length === 0) {
        grid.innerHTML = '<p style="grid-column: 1/-1; text-align: center;">Loading parking slots...</p>';
        return;
    }
    
    slots.forEach(slot => {
        const slotDiv = document.createElement('div');
        slotDiv.className = `parking-slot ${slot.status}`;
        slotDiv.textContent = slot.slot_number;
        slotDiv.onclick = () => handleSlotClick(slot);
        grid.appendChild(slotDiv);
    });
}

// Handle slot click
function handleSlotClick(slot) {
    if (slot.status === 'available') {
        const user = JSON.parse(localStorage.getItem('currentUser'));
        if (user) {
            if (confirm(`Book parking slot ${slot.slot_number}?`)) {
                alert('Please go to your dashboard to complete the booking.');
                window.location.href = 'dashboard.html';
            }
        } else {
            alert('Please login to book a parking slot.');
            window.location.href = 'login.html';
        }
    } else {
        alert(`Slot ${slot.slot_number} is currently ${slot.status}.`);
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    renderParkingSlots();
});
