// Student Dashboard JS - Attendance Marking & Tracking
const API_BASE_URL = 'http://localhost:8080/api';

// State
let studentId = localStorage.getItem('userId') || 'student';

// DOM Elements
const form = document.getElementById('attendanceForm');
const sessionIdInput = document.getElementById('sessionId');
const tokenInput = document.getElementById('token');
const markBtn = document.getElementById('markBtn');
const errorMsg = document.getElementById('errorMsg');
const successMsg = document.getElementById('successMsg');
const warningMsg = document.getElementById('warningMsg');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
    loadAttendanceRecords();
});

// Setup Event Listeners
function setupEventListeners() {
    form.addEventListener('submit', handleMarkAttendance);
}

// Handle Mark Attendance
async function handleMarkAttendance(e) {
    e.preventDefault();
    
    // Prevent double submission
    if (markBtn.disabled) {
        return;
    }
    
    // Clear previous messages
    clearMessages();
    
    // Clear previous error states
    document.querySelectorAll('input').forEach(el => {
        el.classList.remove('error');
    });
    document.querySelectorAll('.error-text').forEach(el => {
        el.classList.remove('show');
    });
    
    // Validate inputs
    const sessionId = sessionIdInput.value.trim();
    const token = tokenInput.value.trim();
    let isValid = true;
    
    if (!sessionId) {
        document.querySelector('#sessionId ~ .error-text').textContent = 'Session ID is required';
        document.querySelector('#sessionId ~ .error-text').classList.add('show');
        document.getElementById('sessionId').classList.add('error');
        isValid = false;
    }
    
    if (!token) {
        document.querySelector('#token ~ .error-text').textContent = 'Token is required';
        document.querySelector('#token ~ .error-text').classList.add('show');
        document.getElementById('token').classList.add('error');
        isValid = false;
    }
    
    if (!isValid) {
        showError('Please fill in all required fields');
        return;
    }
    
    // Disable button during request
    markBtn.disabled = true;
    
    try {
        // Get student location
        const location = await getStudentLocation();
        
        // Prepare request data
        const requestData = {
            sessionId: sessionId,
            token: token,
            studentLatitude: location.latitude,
            studentLongitude: location.longitude
        };
        
        // Send POST request with timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 10000);

        const response = await fetch(`${API_BASE_URL}/student/markAttendance`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestData),
            signal: controller.signal
        });

        clearTimeout(timeoutId);
        
        const data = await response.json().catch(() => ({ message: 'Server error' }));
        
        if (response.ok) {
            showSuccess('✅ Attendance marked successfully!');
            form.reset();
            // Reload attendance records
            setTimeout(() => {
                loadAttendanceRecords();
            }, 1500);
        } else {
            // Handle specific error cases
            handleAttendanceError(data.message || 'Failed to mark attendance');
        }
    } catch (error) {
        console.error('Error:', error);
        
        let errorMessage = '';
        if (error.name === 'AbortError') {
            errorMessage = 'Request timed out. Please try again.';
        } else if (error instanceof TypeError) {
            errorMessage = 'Network error. Please check your connection.';
        } else {
            errorMessage = error.message || 'An unexpected error occurred';
        }
        
        showError(errorMessage);
    } finally {
        markBtn.disabled = false;
    }
}

// Get Student Location
function getStudentLocation() {
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

// Handle Attendance Error
function handleAttendanceError(message) {
    let errorText = '❌ ';
    
    if (message.toLowerCase().includes('expired') || message.toLowerCase().includes('expired')) {
        errorText += 'Session has expired. Please ask your teacher to generate a new QR code.';
    } else if (message.toLowerCase().includes('outside') || message.toLowerCase().includes('radius')) {
        errorText += 'You are outside the allowed radius. Please move closer to the classroom.';
    } else if (message.toLowerCase().includes('already') || message.toLowerCase().includes('duplicate')) {
        errorText += 'You have already marked attendance for this session.';
    } else if (message.toLowerCase().includes('invalid') || message.toLowerCase().includes('not found')) {
        errorText += 'Invalid Session ID or Token. Please check and try again.';
    } else if (message.toLowerCase().includes('geolocation')) {
        errorText += 'Location access denied. Please enable location permissions.';
    } else {
        errorText += message;
    }
    
    showError(errorText);
}

// Load Attendance Records
async function loadAttendanceRecords() {
    try {
        const response = await fetch(`${API_BASE_URL}/student/attendance/${studentId}`);
        
        if (response.ok) {
            const data = await response.json();
            populateAttendanceTable(data);
            checkAttendanceWarning(data);
        }
    } catch (error) {
        console.error('Error loading attendance records:', error);
    }
}

// Populate Attendance Table
function populateAttendanceTable(records) {
    if (!records || !Array.isArray(records) || records.length === 0) {
        const tbody = document.querySelector('#attendanceTable tbody');
        tbody.innerHTML = '<tr><td colspan="4">No attendance records found</td></tr>';
        return;
    }
    
    const tbody = document.querySelector('#attendanceTable tbody');
    tbody.innerHTML = records.map(record => `
        <tr>
            <td>${record.subjectName || 'N/A'}</td>
            <td>${formatDate(record.date)}</td>
            <td>${record.time || 'N/A'}</td>
            <td><span class="status ${record.status ? record.status.toLowerCase() : 'absent'}">${record.status || 'Absent'}</span></td>
        </tr>
    `).join('');
}

// Format Date
function formatDate(dateStr) {
    if (!dateStr) return 'N/A';
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}

// Check Attendance Warning
function checkAttendanceWarning(records) {
    if (!records || records.length === 0) return;
    
    // Calculate attendance percentage
    const presentCount = records.filter(r => r.status === 'Present').length;
    const totalCount = records.length;
    const percentage = (presentCount / totalCount) * 100;
    
    // Display percentage
    const percentDiv = document.getElementById('attendancePercent');
    percentDiv.innerHTML = `<h3>Overall Attendance: ${percentage.toFixed(1)}%</h3>`;
    
    // Show warning if below 75%
    if (percentage < 75) {
        showWarning(`⚠️ Warning: Your attendance is ${percentage.toFixed(1)}%. You need to maintain at least 75% attendance.`);
    }
}

// Show Error Message
function showError(message) {
    errorMsg.textContent = message;
    errorMsg.classList.add('active');
    successMsg.classList.remove('active');
    warningMsg.classList.remove('active');
}

// Show Success Message
function showSuccess(message) {
    successMsg.textContent = message;
    successMsg.classList.add('active');
    errorMsg.classList.remove('active');
    warningMsg.classList.remove('active');
}

// Show Warning Message
function showWarning(message) {
    warningMsg.textContent = message;
    warningMsg.classList.add('active');
    errorMsg.classList.remove('active');
}

// Clear Messages
function clearMessages() {
    errorMsg.classList.remove('active');
    successMsg.classList.remove('active');
    warningMsg.classList.remove('active');
}