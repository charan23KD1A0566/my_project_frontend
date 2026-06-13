// Admin Dashboard JS
const API_BASE_URL = 'http://localhost:8080/api';

// Store auth data
let authToken = localStorage.getItem('token');
let authRole = localStorage.getItem('role');
let authName = localStorage.getItem('name');
let authUserId = localStorage.getItem('userId');

// Store data for dropdowns
let departmentsList = [];
let yearsList = [];
let sectionsList = [];

// DOM Elements
const sidebar = document.querySelector('.sidebar');
const toggleSidebarBtn = document.getElementById('toggleSidebar');
const logoutBtn = document.getElementById('logoutBtn');
const navLinks = document.querySelectorAll('.nav-link');
const contentSections = document.querySelectorAll('.content-section');
const userNameDisplay = document.getElementById('userName');
const pageNameDisplay = document.getElementById('pageName');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Check authentication
    if (!authToken || (authRole && authRole.toLowerCase()) !== 'admin') {
        window.location.href = 'login.html';
        return;
    }

    // Set user name
    userNameDisplay.textContent = authName || 'Admin';

    // Setup event listeners
    setupEventListeners();

    // Load initial data
    loadDashboard();
    loadDropdownData();
});

// Setup Event Listeners
function setupEventListeners() {
    // Navigation
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const sectionId = link.dataset.section;
            switchSection(sectionId);
        });
    });

    // Logout
    logoutBtn.addEventListener('click', handleLogout);

    // Sidebar toggle
    if (toggleSidebarBtn) {
        toggleSidebarBtn.addEventListener('click', toggleSidebar);
    }

    // Department Form
    const departmentForm = document.getElementById('departmentForm');
    if (departmentForm) {
        departmentForm.addEventListener('submit', handleAddDepartment);
    }

    // Section Form
    const sectionForm = document.getElementById('sectionForm');
    if (sectionForm) {
        sectionForm.addEventListener('submit', handleAddSection);
    }

    // Year Form
    const yearForm = document.getElementById('yearForm');
    if (yearForm) {
        yearForm.addEventListener('submit', handleAddYear);
    }

    // Subject Form
    const subjectForm = document.getElementById('subjectForm');
    if (subjectForm) {
        subjectForm.addEventListener('submit', handleAddSubject);
    }

    // Teacher Form
    const teacherForm = document.getElementById('teacherForm');
    if (teacherForm) {
        teacherForm.addEventListener('submit', handleAddTeacher);
    }

    // Student Form
    const studentForm = document.getElementById('studentForm');
    if (studentForm) {
        studentForm.addEventListener('submit', handleAddStudent);
    }

    // Student year change - load sections
    const studentYearSelect = document.getElementById('studentYear');
    if (studentYearSelect) {
        studentYearSelect.addEventListener('change', loadStudentSections);
    }

    // Student department change - load sections
    const studentDeptSelect = document.getElementById('studentDept');
    if (studentDeptSelect) {
        studentDeptSelect.addEventListener('change', loadStudentSections);
    }
}

// Load Dropdown Data
async function loadDropdownData() {
    try {
        // Load Departments
        const deptResponse = await fetch(`${API_BASE_URL}/admin/departments`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (deptResponse.ok) {
            departmentsList = await deptResponse.json();
            populateDepartmentDropdowns();
        }

        // Load Years
        const yearResponse = await fetch(`${API_BASE_URL}/admin/years`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (yearResponse.ok) {
            yearsList = await yearResponse.json();
            populateYearDropdowns();
        }

        // Load Sections
        const sectionResponse = await fetch(`${API_BASE_URL}/admin/sections`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (sectionResponse.ok) {
            sectionsList = await sectionResponse.json();
        }

    } catch (error) {
        console.error('Error loading dropdown data:', error);
    }
}

// Populate Department Dropdowns
function populateDepartmentDropdowns() {
    const departmentSelects = [
        document.getElementById('sectionDept'),
        document.getElementById('subjectDept'),
        document.getElementById('teacherDept'),
        document.getElementById('studentDept')
    ];

    departmentSelects.forEach(select => {
        if (select) {
            select.innerHTML = '<option value="">Select Department</option>';
            departmentsList.forEach(dept => {
                const option = document.createElement('option');
                option.value = dept.id;
                option.textContent = dept.name;
                select.appendChild(option);
            });
        }
    });
}

// Populate Year Dropdowns
function populateYearDropdowns() {
    const yearSelects = [
        document.getElementById('sectionYear'),
        document.getElementById('studentYear')
    ];

    yearSelects.forEach(select => {
        if (select) {
            select.innerHTML = '<option value="">Select Year</option>';
            yearsList.forEach(year => {
                const option = document.createElement('option');
                option.value = year.id;
                option.textContent = year.name;
                select.appendChild(option);
            });
        }
    });
}

// Load Student Sections based on Year and Department
function loadStudentSections() {
    const yearId = document.getElementById('studentYear').value;
    const deptId = document.getElementById('studentDept').value;
    const sectionSelect = document.getElementById('studentSection');

    if (!yearId || !deptId) {
        sectionSelect.innerHTML = '<option value="">Select Section</option>';
        return;
    }

    // Filter sections based on year and department
    const filteredSections = sectionsList.filter(sec => 
        sec.yearId === yearId && sec.departmentId === deptId
    );

    sectionSelect.innerHTML = '<option value="">Select Section</option>';
    filteredSections.forEach(section => {
        const option = document.createElement('option');
        option.value = section.id;
        option.textContent = section.name;
        sectionSelect.appendChild(option);
    });
}

// Switch Section
function switchSection(sectionId) {
    // Hide all sections
    contentSections.forEach(section => {
        section.classList.remove('active');
    });

    // Show selected section
    const selectedSection = document.getElementById(sectionId);
    if (selectedSection) {
        selectedSection.classList.add('active');
    }

    // Update nav links
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.dataset.section === sectionId) {
            link.classList.add('active');
        }
    });

    // Update page name
    const pageName = navLinks.find(l => l.dataset.section === sectionId)?.querySelector('.label')?.textContent;
    if (pageName) {
        pageNameDisplay.textContent = pageName;
    }

    // Load section-specific data
    loadSectionData(sectionId);
}

// Load Section Data
async function loadSectionData(sectionId) {
    try {
        switch (sectionId) {
            case 'dashboard':
                await loadDashboard();
                break;
        }
    } catch (error) {
        console.error('Error loading section:', error);
    }
}

// Load Dashboard
async function loadDashboard() {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/dashboard`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (response.ok) {
            const data = await response.json();
            document.getElementById('totalUsers').textContent = data.totalUsers || 0;
            document.getElementById('totalClasses').textContent = data.totalClasses || 0;
            document.getElementById('todayAttendance').textContent = data.todayAttendance || '0%';
            document.getElementById('qrScans').textContent = data.qrScans || 0;
        }
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

// ===== FORM HANDLERS =====

// Handle Add Department
async function handleAddDepartment(e) {
    e.preventDefault();

    const name = document.getElementById('deptName').value.trim();
    const code = document.getElementById('deptCode').value.trim();
    const description = document.getElementById('deptDesc').value.trim();
    const messageEl = document.getElementById('deptMessage');

    // Validate
    if (!name || !code) {
        showFormMessage(messageEl, 'Please fill all required fields', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/departments`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name, code, description })
        });

        const data = await response.json();

        if (response.ok) {
            showFormMessage(messageEl, 'Department added successfully', 'success');
            e.target.reset();
            loadDropdownData();
            setTimeout(() => {
                switchSection('dashboard');
            }, 2000);
        } else {
            showFormMessage(messageEl, data.message || 'Error adding department', 'error');
        }
    } catch (error) {
        console.error('Error adding department:', error);
        showFormMessage(messageEl, 'Error adding department', 'error');
    }
}

// Handle Add Section
async function handleAddSection(e) {
    e.preventDefault();

    const name = document.getElementById('sectionName').value.trim();
    const departmentId = document.getElementById('sectionDept').value;
    const yearId = document.getElementById('sectionYear').value;
    const capacity = document.getElementById('sectionCapacity').value;
    const messageEl = document.getElementById('sectionMessage');

    // Validate
    if (!name || !departmentId || !yearId) {
        showFormMessage(messageEl, 'Please fill all required fields', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/sections`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name, departmentId, yearId, capacity: capacity || 60 })
        });

        const data = await response.json();

        if (response.ok) {
            showFormMessage(messageEl, 'Section added successfully', 'success');
            e.target.reset();
            loadDropdownData();
            setTimeout(() => {
                switchSection('dashboard');
            }, 2000);
        } else {
            showFormMessage(messageEl, data.message || 'Error adding section', 'error');
        }
    } catch (error) {
        console.error('Error adding section:', error);
        showFormMessage(messageEl, 'Error adding section', 'error');
    }
}

// Handle Add Year
async function handleAddYear(e) {
    e.preventDefault();

    const name = document.getElementById('yearName').value.trim();
    const code = document.getElementById('yearCode').value.trim();
    const startDate = document.getElementById('yearStart').value;
    const endDate = document.getElementById('yearEnd').value;
    const messageEl = document.getElementById('yearMessage');

    // Validate
    if (!name || !code || !startDate || !endDate) {
        showFormMessage(messageEl, 'Please fill all required fields', 'error');
        return;
    }

    // Validate dates
    if (new Date(startDate) >= new Date(endDate)) {
        showFormMessage(messageEl, 'End date must be after start date', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/years`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name, code, startDate, endDate })
        });

        const data = await response.json();

        if (response.ok) {
            showFormMessage(messageEl, 'Year added successfully', 'success');
            e.target.reset();
            loadDropdownData();
            setTimeout(() => {
                switchSection('dashboard');
            }, 2000);
        } else {
            showFormMessage(messageEl, data.message || 'Error adding year', 'error');
        }
    } catch (error) {
        console.error('Error adding year:', error);
        showFormMessage(messageEl, 'Error adding year', 'error');
    }
}

// Handle Add Subject
async function handleAddSubject(e) {
    e.preventDefault();

    const name = document.getElementById('subjectName').value.trim();
    const code = document.getElementById('subjectCode').value.trim();
    const departmentId = document.getElementById('subjectDept').value;
    const credits = document.getElementById('subjectCredits').value;
    const description = document.getElementById('subjectDesc').value.trim();
    const messageEl = document.getElementById('subjectMessage');

    // Validate
    if (!name || !code || !departmentId) {
        showFormMessage(messageEl, 'Please fill all required fields', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/subjects`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name, code, departmentId, credits: credits || 4, description })
        });

        const data = await response.json();

        if (response.ok) {
            showFormMessage(messageEl, 'Subject added successfully', 'success');
            e.target.reset();
            setTimeout(() => {
                switchSection('dashboard');
            }, 2000);
        } else {
            showFormMessage(messageEl, data.message || 'Error adding subject', 'error');
        }
    } catch (error) {
        console.error('Error adding subject:', error);
        showFormMessage(messageEl, 'Error adding subject', 'error');
    }
}

// Handle Add Teacher
async function handleAddTeacher(e) {
    e.preventDefault();

    const name = document.getElementById('teacherName').value.trim();
    const email = document.getElementById('teacherEmail').value.trim();
    const phone = document.getElementById('teacherPhone').value.trim();
    const departmentId = document.getElementById('teacherDept').value;
    const qualification = document.getElementById('teacherQual').value.trim();
    const experience = document.getElementById('teacherExp').value;
    const password = document.getElementById('teacherPassword').value;
    const messageEl = document.getElementById('teacherMessage');

    // Validate
    if (!name || !email || !departmentId || !qualification || !password) {
        showFormMessage(messageEl, 'Please fill all required fields', 'error');
        return;
    }

    // Validate email
    if (!isValidEmail(email)) {
        showFormMessage(messageEl, 'Please enter a valid email', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/teachers`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                name,
                email,
                phone: phone || null,
                departmentId,
                qualification,
                experience: experience || 0,
                password
            })
        });

        const data = await response.json();

        if (response.ok) {
            showFormMessage(messageEl, 'Teacher added successfully', 'success');
            e.target.reset();
            setTimeout(() => {
                switchSection('dashboard');
            }, 2000);
        } else {
            showFormMessage(messageEl, data.message || 'Error adding teacher', 'error');
        }
    } catch (error) {
        console.error('Error adding teacher:', error);
        showFormMessage(messageEl, 'Error adding teacher', 'error');
    }
}

// Handle Add Student
async function handleAddStudent(e) {
    e.preventDefault();

    const name = document.getElementById('studentName').value.trim();
    const email = document.getElementById('studentEmail').value.trim();
    const rollNumber = document.getElementById('studentRoll').value.trim();
    const phone = document.getElementById('studentPhone').value.trim();
    const departmentId = document.getElementById('studentDept').value;
    const yearId = document.getElementById('studentYear').value;
    const sectionId = document.getElementById('studentSection').value;
    const dateOfBirth = document.getElementById('studentDOB').value;
    const password = document.getElementById('studentPassword').value;
    const messageEl = document.getElementById('studentMessage');

    // Validate
    if (!name || !email || !rollNumber || !departmentId || !yearId || !sectionId || !password) {
        showFormMessage(messageEl, 'Please fill all required fields', 'error');
        return;
    }

    // Validate email
    if (!isValidEmail(email)) {
        showFormMessage(messageEl, 'Please enter a valid email', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/students`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                name,
                email,
                rollNumber,
                phone: phone || null,
                departmentId,
                yearId,
                sectionId,
                dateOfBirth: dateOfBirth || null,
                password
            })
        });

        const data = await response.json();

        if (response.ok) {
            showFormMessage(messageEl, 'Student added successfully', 'success');
            e.target.reset();
            setTimeout(() => {
                switchSection('dashboard');
            }, 2000);
        } else {
            showFormMessage(messageEl, data.message || 'Error adding student', 'error');
        }
    } catch (error) {
        console.error('Error adding student:', error);
        showFormMessage(messageEl, 'Error adding student', 'error');
    }
}

// ===== UTILITY FUNCTIONS =====

// Show Form Message
function showFormMessage(element, message, type) {
    element.textContent = message;
    element.className = 'form-message ' + type;
}

// Validate Email
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// Toggle Sidebar
function toggleSidebar() {
    sidebar.classList.toggle('collapsed');
    const nav = sidebar.querySelector('.sidebar-nav');
    const footer = sidebar.querySelector('.sidebar-footer');
    if (nav) nav.classList.toggle('show');
    if (footer) footer.classList.toggle('show');
}

// Logout
function handleLogout() {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('token');
        localStorage.removeItem('role');
        localStorage.removeItem('name');
        localStorage.removeItem('userId');
        window.location.href = 'login.html';
    }
}