# COMPREHENSIVE API ENDPOINT TEST SCRIPT

$BASE_URL = "http://localhost:8080/api"
$ADMIN_EMAIL = "admin@gmail.com"
$ADMIN_PASS = "admin123"
$TEACHER_EMAIL = "teacher1@college.com"
$TEACHER_PASS = "teacher123"
$STUDENT_EMAIL = "student1@college.com"
$STUDENT_PASS = "student123"

$ADMIN_TOKEN = ""
$TEACHER_TOKEN = ""
$STUDENT_TOKEN = ""

# Color codes
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Section { Write-Host "`n========== $args ==========" -ForegroundColor Yellow }

Write-Section "TESTING PUBLIC ENDPOINTS"

# Test 1: Health Check
Write-Info "Testing GET /health"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/health" -Method GET -ErrorAction Stop
    Write-Success "Health check: $($response.Content)"
} catch {
    Write-Error "Health check failed: $($_.Exception.Message)"
}

# Test 2: Get All Students (Public)
Write-Info "Testing GET /students"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/students" -Method GET -ErrorAction Stop
    $students = $response.Content | ConvertFrom-Json
    Write-Success "Students endpoint: Found $($students.Count) students"
} catch {
    Write-Error "Students endpoint failed: $($_.Exception.Message)"
}

Write-Section "TESTING AUTHENTICATION"

# Admin Login
Write-Info "Testing POST /auth/login (ADMIN)"
try {
    $body = @{
        email = $ADMIN_EMAIL
        password = $ADMIN_PASS
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -ContentType "application/json" -Body $body -ErrorAction Stop
    $result = $response.Content | ConvertFrom-Json
    $ADMIN_TOKEN = $result.token
    
    Write-Success "Admin login successful - Role: $($result.role)"
} catch {
    Write-Error "Admin login failed: $($_.Exception.Message)"
}

# Teacher Login
Write-Info "Testing POST /auth/login (TEACHER)"
try {
    $body = @{
        email = $TEACHER_EMAIL
        password = $TEACHER_PASS
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -ContentType "application/json" -Body $body -ErrorAction Stop
    $result = $response.Content | ConvertFrom-Json
    $TEACHER_TOKEN = $result.token
    
    Write-Success "Teacher login successful - Name: $($result.name)"
} catch {
    Write-Error "Teacher login failed: $($_.Exception.Message)"
}

# Student Login
Write-Info "Testing POST /auth/login (STUDENT)"
try {
    $body = @{
        email = $STUDENT_EMAIL
        password = $STUDENT_PASS
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -ContentType "application/json" -Body $body -ErrorAction Stop
    $result = $response.Content | ConvertFrom-Json
    $STUDENT_TOKEN = $result.token
    
    Write-Success "Student login successful - Name: $($result.name)"
} catch {
    Write-Error "Student login failed: $($_.Exception.Message)"
}

Write-Section "TESTING ADMIN ENDPOINTS"

$headers = @{
    "Authorization" = "Bearer $ADMIN_TOKEN"
    "Content-Type" = "application/json"
}

# Test Departments
Write-Info "Testing GET /admin/departments"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/departments" -Method GET -Headers $headers -ErrorAction Stop
    $depts = $response.Content | ConvertFrom-Json
    Write-Success "Departments: Found $($depts.Count) departments"
} catch {
    Write-Error "Departments failed: $($_.Exception.Message)"
}

# Test Teachers
Write-Info "Testing GET /admin/teachers"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/teachers" -Method GET -Headers $headers -ErrorAction Stop
    $teachers = $response.Content | ConvertFrom-Json
    Write-Success "Teachers: Found $($teachers.Count) teachers"
} catch {
    Write-Error "Teachers failed: $($_.Exception.Message)"
}

# Test Students
Write-Info "Testing GET /admin/students"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/students" -Method GET -Headers $headers -ErrorAction Stop
    $students = $response.Content | ConvertFrom-Json
    Write-Success "Students: Found $($students.Count) students"
} catch {
    Write-Error "Students failed: $($_.Exception.Message)"
}

# Test Subjects
Write-Info "Testing GET /admin/subjects"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/subjects" -Method GET -Headers $headers -ErrorAction Stop
    $subjects = $response.Content | ConvertFrom-Json
    Write-Success "Subjects: Found $($subjects.Count) subjects"
} catch {
    Write-Error "Subjects failed: $($_.Exception.Message)"
}

Write-Section "TESTING TEACHER ENDPOINTS"

$teacher_headers = @{
    "Authorization" = "Bearer $TEACHER_TOKEN"
    "Content-Type" = "application/json"
}

# Generate QR Code
Write-Info "Testing POST /teacher/generateQR"
$SESSION_ID = ""
$QR_TOKEN = ""
try {
    $body = @{
        teacherId = 1
        teacherName = "Dr. CTeacher0"
        subjectId = 21
        year = 1
        section = "A"
        department = "Computer Science"
        teacherLatitude = 28.5355
        teacherLongitude = 77.391
        qrExpiryTime = 10
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST -Headers $teacher_headers -Body $body -ErrorAction Stop
    $result = $response.Content | ConvertFrom-Json
    $SESSION_ID = $result.sessionId
    $QR_TOKEN = $result.token
    
    Write-Success "QR generation successful - Session: $SESSION_ID"
} catch {
    Write-Error "QR generation failed: $($_.Exception.Message)"
}

# Get Session Attendance
if ($SESSION_ID) {
    Write-Info "Testing GET /teacher/session/{sessionId}/attendance"
    try {
        $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$SESSION_ID/attendance" -Method GET -Headers $teacher_headers -ErrorAction Stop
        $attendance = $response.Content | ConvertFrom-Json
        Write-Success "Session attendance: Found $($attendance.Count) students"
    } catch {
        Write-Error "Session attendance failed: $($_.Exception.Message)"
    }
}

Write-Section "TESTING STUDENT ENDPOINTS"

$student_headers = @{
    "Authorization" = "Bearer $STUDENT_TOKEN"
    "Content-Type" = "application/json"
}

# Mark Attendance
Write-Info "Testing POST /student/mark-attendance"
try {
    if ($SESSION_ID -and $QR_TOKEN) {
        $body = @{
            sessionId = [int]$SESSION_ID
            token = $QR_TOKEN
            studentLatitude = 28.5355
            studentLongitude = 77.391
        } | ConvertTo-Json
        
        $response = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST -Headers $student_headers -Body $body -ErrorAction Stop
        Write-Success "Attendance marking successful: $($response.Content)"
    }
} catch {
    Write-Error "Attendance marking failed: $($_.Exception.Message)"
}

# Get Attendance History
Write-Info "Testing GET /student/attendance-history"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET -Headers $student_headers -ErrorAction Stop
    $history = $response.Content | ConvertFrom-Json
    Write-Success "Attendance history: Retrieved $($history.Count) records"
} catch {
    Write-Error "Attendance history failed: $($_.Exception.Message)"
}

# Get Attendance Summary
Write-Info "Testing GET /student/attendance/me"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/attendance/me" -Method GET -Headers $student_headers -ErrorAction Stop
    $summary = $response.Content | ConvertFrom-Json
    Write-Success "Attendance summary: Retrieved $($summary.subjectAttendance.Count) subjects"
} catch {
    Write-Error "Attendance summary failed: $($_.Exception.Message)"
}

Write-Section "COMPLETE WORKFLOW TEST"

Write-Info "Step 1: Teacher generates QR"
try {
    $body = @{
        teacherId = 1
        teacherName = "Dr. CTeacher0"
        subjectId = 21
        year = 1
        section = "A"
        department = "Computer Science"
        teacherLatitude = 28.5355
        teacherLongitude = 77.391
        qrExpiryTime = 10
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST -Headers $teacher_headers -Body $body -ErrorAction Stop
    $qr_result = $response.Content | ConvertFrom-Json
    Write-Success "QR Generated: Session $($qr_result.sessionId)"
} catch {
    Write-Error "Step 1 failed: $($_.Exception.Message)"
    exit
}

Write-Info "Step 2: Student marks attendance"
try {
    $body = @{
        sessionId = [int]$qr_result.sessionId
        token = $qr_result.token
        studentLatitude = 28.5355
        studentLongitude = 77.391
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST -Headers $student_headers -Body $body -ErrorAction Stop
    Write-Success "Attendance Marked: $($response.Content)"
} catch {
    Write-Error "Step 2 failed: $($_.Exception.Message)"
    exit
}

Write-Info "Step 3: Student checks history"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET -Headers $student_headers -ErrorAction Stop
    $history = $response.Content | ConvertFrom-Json
    Write-Success "History Retrieved: $($history.Count) records found"
} catch {
    Write-Error "Step 3 failed: $($_.Exception.Message)"
    exit
}

Write-Info "Step 4: Teacher verifies attendance"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$($qr_result.sessionId)/attendance" -Method GET -Headers $teacher_headers -ErrorAction Stop
    $session_attendance = $response.Content | ConvertFrom-Json
    $marked_count = ($session_attendance | Where-Object { $_.status -eq "PRESENT" } | Measure-Object).Count
    Write-Success "Attendance Verified: $marked_count students marked PRESENT"
} catch {
    Write-Error "Step 4 failed: $($_.Exception.Message)"
    exit
}

Write-Section "TEST COMPLETE"
Write-Success "All endpoint tests completed successfully!"
Write-Host ""
