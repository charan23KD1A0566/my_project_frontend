// Login JS - Handle login form submission
const loginForm = document.getElementById('loginForm');
const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');
const roleSelect = document.getElementById('role');
const loginBtn = document.querySelector('.btn-login');
const loginText = document.getElementById('loginText');
const loginSpinner = document.getElementById('loginSpinner');
const formError = document.getElementById('formError');
const rememberMe = document.getElementById('rememberMe');

// API Configuration
const API_BASE_URL = 'http://localhost:8080/api';

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Load saved email if remember me was checked
    const savedEmail = localStorage.getItem('savedEmail');
    const wasRemembered = localStorage.getItem('rememberMe');
    
    if (savedEmail && wasRemembered === 'true') {
        emailInput.value = savedEmail;
        rememberMe.checked = true;
    }

    loginForm.addEventListener('submit', handleLogin);
});

// Handle Login
async function handleLogin(e) {
    e.preventDefault();
    
    // Clear previous errors
    clearErrors();
    
    // Validate inputs
    if (!validateInputs()) {
        return;
    }

    // Show loading state
    setLoadingState(true);

    try {
        console.log('Attempting login to:', `${API_BASE_URL}/auth/login`);
        
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            credentials: 'include',
            body: JSON.stringify({
                email: emailInput.value.trim(),
                password: passwordInput.value,
                role: roleSelect.value
            })
        });

        console.log('Response status:', response.status);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Server error response:', errorText);
            throw new Error(`Server returned ${response.status}: ${errorText || 'Login failed'}`);
        }

        const data = await response.json();
        console.log('Login successful, received token:', data.token ? 'YES' : 'NO');

        // Store auth data
        localStorage.setItem('token', data.token);
        localStorage.setItem('role', data.role);
        localStorage.setItem('name', data.name);
        localStorage.setItem('userId', data.userId);

        // Handle remember me
        if (rememberMe.checked) {
            localStorage.setItem('savedEmail', emailInput.value);
            localStorage.setItem('rememberMe', 'true');
        } else {
            localStorage.removeItem('savedEmail');
            localStorage.removeItem('rememberMe');
        }

        // Redirect based on role
        redirectToRole(data.role);

    } catch (error) {
        console.error('Login error details:', {
            message: error.message,
            name: error.name,
            stack: error.stack
        });

        let errorMessage = error.message || 'An error occurred during login';
        
        // Check for CORS errors
        if (error.message.includes('Failed to fetch') || error.name === 'TypeError') {
            errorMessage = 'Network error - Backend may be offline or unreachable. If the backend is on Render free tier, it may take 30-60 seconds to wake up on first request. Try again shortly.';
        }
        
        showFormError(errorMessage);
    } finally {
        setLoadingState(false);
    }
}

// Validate Inputs
function validateInputs() {
    let isValid = true;

    // Email validation
    if (!emailInput.value.trim()) {
        showError('emailError', 'Email is required');
        isValid = false;
    } else if (!isValidEmail(emailInput.value)) {
        showError('emailError', 'Please enter a valid email');
        isValid = false;
    }

    // Password validation
    if (!passwordInput.value) {
        showError('passwordError', 'Password is required');
        isValid = false;
    }

    // Role validation
    if (!roleSelect.value) {
        showError('roleError', 'Please select a role');
        isValid = false;
    }

    return isValid;
}

// Show Error
function showError(elementId, message) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = message;
        element.classList.add('show');
    }
}

// Show Form Error
function showFormError(message) {
    formError.textContent = message;
    formError.classList.add('show');
}

// Clear Errors
function clearErrors() {
    document.querySelectorAll('.error-message').forEach(el => {
        el.classList.remove('show');
        el.textContent = '';
    });
}

// Validate Email
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// Set Loading State
function setLoadingState(loading) {
    if (loading) {
        loginBtn.disabled = true;
        loginText.style.display = 'none';
        loginSpinner.style.display = 'inline-block';
    } else {
        loginBtn.disabled = false;
        loginText.style.display = 'inline';
        loginSpinner.style.display = 'none';
    }
}

// Redirect Based on Role
function redirectToRole(role) {
    const dashboardMap = {
        'admin': 'admin-dashboard.html',
        'teacher': 'teacher-dashboard.html',
        'student': 'student-dashboard.html'
    };

    const redirectUrl = dashboardMap[role.toLowerCase()] || 'login.html';
    window.location.href = redirectUrl;
}