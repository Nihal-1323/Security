// Handle login
document.getElementById('loginForm')?.addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const role = document.getElementById('role').value;
    
    const messageDiv = document.getElementById('message');
    
    try {
        const response = await fetch('api/auth.php?action=login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, password, role })
        });
        
        const data = await response.json();
        
        if (data.success) {
            localStorage.setItem('currentUser', JSON.stringify(data.user));
            messageDiv.textContent = 'Login successful! Redirecting...';
            messageDiv.className = 'message success';
            
            setTimeout(() => {
                window.location.href = 'dashboard.html';
            }, 1000);
        } else {
            messageDiv.textContent = data.message || 'Invalid credentials';
            messageDiv.className = 'message error';
        }
    } catch (error) {
        messageDiv.textContent = 'Connection error. Please try again.';
        messageDiv.className = 'message error';
    }
});

// Handle registration
document.getElementById('registerForm')?.addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const fullname = document.getElementById('fullname').value;
    const email = document.getElementById('email').value;
    const phone = document.getElementById('phone').value;
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    const role = document.getElementById('role').value;
    
    const messageDiv = document.getElementById('message');
    
    // Validate passwords match
    if (password !== confirmPassword) {
        messageDiv.textContent = 'Passwords do not match!';
        messageDiv.className = 'message error';
        return;
    }
    
    // Validate password strength
    if (password.length < 6) {
        messageDiv.textContent = 'Password must be at least 6 characters long!';
        messageDiv.className = 'message error';
        return;
    }
    
    // Show loading message
    messageDiv.textContent = 'Creating account...';
    messageDiv.className = 'message';
    
    try {
        const requestData = { fullname, email, phone, username, password, role };
        console.log('Sending registration request:', { ...requestData, password: '***' });
        
        const response = await fetch('api/auth.php?action=register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestData)
        });
        
        console.log('Response status:', response.status);
        console.log('Response headers:', response.headers);
        
        // Get response text first to check if it's valid JSON
        const responseText = await response.text();
        console.log('Response text:', responseText);
        
        // Try to parse as JSON
        let data;
        try {
            data = JSON.parse(responseText);
        } catch (parseError) {
            console.error('JSON parse error:', parseError);
            console.error('Response was not valid JSON:', responseText);
            messageDiv.textContent = 'Server error. Check console (F12) for details.';
            messageDiv.className = 'message error';
            return;
        }
        
        console.log('Parsed response:', data);
        
        if (data.success) {
            messageDiv.textContent = 'Registration successful! Redirecting to login...';
            messageDiv.className = 'message success';
            
            setTimeout(() => {
                window.location.href = 'login.html';
            }, 1500);
        } else {
            messageDiv.textContent = data.message || 'Registration failed';
            messageDiv.className = 'message error';
        }
    } catch (error) {
        console.error('Registration error:', error);
        messageDiv.textContent = 'Connection error: ' + error.message;
        messageDiv.className = 'message error';
    }
});
