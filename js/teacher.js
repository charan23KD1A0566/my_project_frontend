// Teacher Dashboard JS - QR Attendance Session Generator
const API_BASE_URL = 'http://localhost:8080/api';

// State
let countdownInterval = null;
let sessionExpiryTime = null;

// DOM Elements
const form = document.getElementById('sessionForm');
const generateBtn = document.getElementById('generateBtn');
const errorMsg = document.getElementById('errorMsg');
const successMsg = document.getElementById('successMsg');
const resultSection = document.getElementById('resultSection');
const loadingDiv = document.getElementById('loading');
const subjectSelect = document.getElementById('subject');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
    loadSubjects();
});

// Setup Event Listeners
function setupEventListeners() {
    form.addEventListener('submit', handleFormSubmit);
}

// Load Subjects from API
async function loadSubjects() {
    try {
        const response = await fetch(`${API_BASE_URL}/subjects`);
        
        if (response.ok) {
            const subjects = await response.json();
            populateSubjectDropdown(subjects);
        } else {
            // Use mock data if API fails
            useMockSubjects();
        }
    } catch (error) {
        console.error('Error loading subjects:', error);
        // Use mock data as fallback
        useMockSubjects();
    }
}

// Mock Subjects (fallback when API is unavailable)
function useMockSubjects() {
    const mockSubjects = [
        { id: '1', name: 'Mathematics' },
        { id: '2', name: 'Physics' },
        { id: '3', name: 'Chemistry' },
        { id: '4', name: 'English' },
        { id: '5', name: 'Computer Science' },
        { id: '6', name: 'History' },
        { id: '7', name: 'Biology' }
    ];
    populateSubjectDropdown(mockSubjects);
    console.log('Using mock subjects (API unavailable)');
}

// Populate Subject Dropdown
function populateSubjectDropdown(subjects) {
    if (!Array.isArray(subjects) || subjects.length === 0) {
        showError('No subjects available');
        return;
    }

    subjectSelect.innerHTML = '<option value="">-- Select Subject --</option>';
    subjects.forEach(subject => {
        const option = document.createElement('option');
        option.value = subject.id;
        option.textContent = subject.name;
        subjectSelect.appendChild(option);
    });
}

// Handle Form Submit
async function handleFormSubmit(e) {
    e.preventDefault();
    
    // Prevent double submission
    if (generateBtn.disabled) {
        return;
    }
    
    // Clear previous messages
    clearMessages();
    
    // Validate form
    if (!validateForm()) {
        return;
    }

    // Show loading
    loadingDiv.style.display = 'block';
    generateBtn.disabled = true;

    try {
        // Get teacher location
        const location = await getTeacherLocation();
        
        // Prepare request data
        const requestData = {
            subjectId: document.getElementById('subject').value,
            year: parseInt(document.getElementById('year').value),
            department: document.getElementById('department').value,
            section: document.getElementById('section').value,
            teacherLatitude: location.latitude,
            teacherLongitude: location.longitude,
            allowedRadius: parseInt(document.getElementById('allowedRadius').value),
            expiryDurationInSeconds: parseInt(document.getElementById('expiryDuration').value)
        };

        // Send POST request with timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 10000);

        const response = await fetch(`${API_BASE_URL}/teacher/createSession`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestData),
            signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (response.ok) {
            const data = await response.json();
            handleSessionResponse(data);
        } else {
            const error = await response.json().catch(() => ({ message: 'Server error' }));
            showError('Error: ' + (error.message || 'Failed to create session'));
            loadingDiv.style.display = 'none';
            generateBtn.disabled = false;
        }
    } catch (error) {
        console.error('Error creating session:', error);
        
        let errorMessage = 'Error: ';
        if (error.name === 'AbortError') {
            errorMessage += 'Request timed out. Please try again.';
        } else if (error instanceof TypeError) {
            errorMessage += 'Network error. Please check your connection.';
        } else {
            errorMessage += error.message || 'An unexpected error occurred';
        }
        
        showError(errorMessage);
        loadingDiv.style.display = 'none';
        generateBtn.disabled = false;
    }
}

// Get Teacher Location
function getTeacherLocation() {
    return new Promise((resolve, reject) => {
        if (!navigator.geolocation) {
            reject(new Error('Geolocation is not supported by this browser'));
            return;
        }

        navigator.geolocation.getCurrentPosition(
            (position) => {
                resolve({
                    latitude: position.coords.latitude,
                    longitude: position.coords.longitude
                });
            },
            (error) => {
                let errorMessage = 'Unable to retrieve location';
                
                switch (error.code) {
                    case error.PERMISSION_DENIED:
                        errorMessage = 'Location permission denied. Please enable location access.';
                        break;
                    case error.POSITION_UNAVAILABLE:
                        errorMessage = 'Location information is unavailable.';
                        break;
                    case error.TIMEOUT:
                        errorMessage = 'Location request timed out.';
                        break;
                }
                
                reject(new Error(errorMessage));
            },
            {
                enableHighAccuracy: true,
                timeout: 10000,
                maximumAge: 0
            }
        );
    });
}

// Handle Session Response
function handleSessionResponse(data) {
    loadingDiv.style.display = 'none';

    // Display success message
    showSuccess('Session created successfully!');

    // Display QR code
    if (data.qrCode) {
        document.getElementById('qrImage').src = data.qrCode;
    }

    // Display session ID
    document.getElementById('sessionId').textContent = data.sessionId || 'N/A';

    // Calculate and display expiry time
    const expiryDuration = parseInt(document.getElementById('expiryDuration').value);
    const expiryTime = new Date(Date.now() + expiryDuration * 1000);
    sessionExpiryTime = expiryTime;

    const formattedTime = expiryTime.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: true
    });

    document.getElementById('expiryTime').textContent = formattedTime;

    // Show result section
    resultSection.classList.add('active');

    // Start countdown timer
    startCountdownTimer(expiryDuration);

    // Disable generate button until session expires
    generateBtn.disabled = true;
}

// Start Countdown Timer
function startCountdownTimer(durationSeconds) {
    let remainingSeconds = durationSeconds;

    // Clear any existing countdown
    if (countdownInterval) {
        clearInterval(countdownInterval);
    }

    // Update countdown display
    updateCountdownDisplay(remainingSeconds);

    // Update every second
    countdownInterval = setInterval(() => {
        remainingSeconds--;

        if (remainingSeconds <= 0) {
            clearInterval(countdownInterval);
            handleSessionExpiry();
        } else {
            updateCountdownDisplay(remainingSeconds);
        }
    }, 1000);
}

// Update Countdown Display
function updateCountdownDisplay(seconds) {
    const countdownEl = document.getElementById('countdown');
    
    // Format time display
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    let displayText = '⏱️ ';
    
    if (hours > 0) {
        displayText += `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    } else if (minutes > 0) {
        displayText += `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    } else {
        displayText += `${String(secs).padStart(2, '0')}`;
    }

    countdownEl.textContent = displayText;
    
    // Remove all style classes first
    countdownEl.classList.remove('warning', 'critical');
    
    // Apply color-coding based on time remaining
    if (seconds <= 10) {
        countdownEl.classList.add('critical');
    } else if (seconds <= 60) {
        countdownEl.classList.add('warning');
    }
}

// Handle Session Expiry
function handleSessionExpiry() {
    clearInterval(countdownInterval);
    
    const countdownEl = document.getElementById('countdown');
    const expiryMsg = document.getElementById('expiryMessage');
    const qrDisplay = document.querySelector('.qr-display');
    
    // Hide QR display immediately
    qrDisplay.style.display = 'none';
    
    // Show expiry message
    expiryMsg.classList.add('active');
    countdownEl.classList.add('expired');
    countdownEl.textContent = '⏱️ 00:00';
    
    // Show error message
    showError('Session has expired. Please generate a new QR code.');

    // Reset form and enable button after delay
    setTimeout(() => {
        resultSection.classList.remove('active');
        expiryMsg.classList.remove('active');
        form.reset();
        generateBtn.disabled = false;
        clearMessages();
    }, 6000);
}

// Validate Form
function validateForm() {
    let isValid = true;
    const errors = {};

    // Clear previous error states
    document.querySelectorAll('input, select').forEach(el => {
        el.classList.remove('error');
    });
    document.querySelectorAll('.error-text').forEach(el => {
        el.classList.remove('show');
    });

    const subject = document.getElementById('subject').value.trim();
    const year = document.getElementById('year').value.trim();
    const section = document.getElementById('section').value.trim();
    const department = document.getElementById('department').value.trim();
    const allowedRadius = document.getElementById('allowedRadius').value.trim();
    const expiryDuration = document.getElementById('expiryDuration').value.trim();

    // Subject validation
    if (!subject) {
        errors.subject = 'Please select a subject';
        document.getElementById('subject').classList.add('error');
        isValid = false;
    }

    // Year validation
    if (!year) {
        errors.year = 'Year is required';
        document.getElementById('year').classList.add('error');
        isValid = false;
    } else if (isNaN(year) || year < 1 || year > 4) {
        errors.year = 'Year must be between 1 and 4';
        document.getElementById('year').classList.add('error');
        isValid = false;
    }

    // Section validation
    if (!section) {
        errors.section = 'Section is required';
        document.getElementById('section').classList.add('error');
        isValid = false;
    } else if (section.length > 1) {
        errors.section = 'Section should be a single character (A, B, C, etc.)';
        document.getElementById('section').classList.add('error');
        isValid = false;
    }

    // Department validation
    if (!department) {
        errors.department = 'Department is required';
        document.getElementById('department').classList.add('error');
        isValid = false;
    }

    // Allowed Radius validation
    if (!allowedRadius) {
        errors.allowedRadius = 'Allowed radius is required';
        document.getElementById('allowedRadius').classList.add('error');
        isValid = false;
    } else if (isNaN(allowedRadius) || allowedRadius < 0 || allowedRadius > 1000) {
        errors.allowedRadius = 'Radius must be between 0 and 1000 meters';
        document.getElementById('allowedRadius').classList.add('error');
        isValid = false;
    }

    // Expiry Duration validation
    if (!expiryDuration) {
        errors.expiryDuration = 'Expiry duration is required';
        document.getElementById('expiryDuration').classList.add('error');
        isValid = false;
    } else if (isNaN(expiryDuration) || expiryDuration < 60 || expiryDuration > 3600) {
        errors.expiryDuration = 'Duration must be between 60 and 3600 seconds';
        document.getElementById('expiryDuration').classList.add('error');
        isValid = false;
    }

    // Display error messages
    Object.keys(errors).forEach(fieldName => {
        const errorEl = document.querySelector(`#${fieldName} ~ .error-text`);
        if (errorEl) {
            errorEl.textContent = errors[fieldName];
            errorEl.classList.add('show');
        }
    });

    if (!isValid) {
        showError('Please fix the errors above before submitting');
    }

    return isValid;
}

// Show Error Message
function showError(message) {
    errorMsg.textContent = message;
    errorMsg.classList.add('active');
    successMsg.classList.remove('active');
}

// Show Success Message
function showSuccess(message) {
    successMsg.textContent = message;
    successMsg.classList.add('active');
    errorMsg.classList.remove('active');
}

// Clear Messages
function clearMessages() {
    errorMsg.classList.remove('active');
    successMsg.classList.remove('active');
}