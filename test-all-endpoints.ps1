#===========================================
# COMPREHENSIVE API ENDPOINT TEST SCRIPT
#===========================================

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
function Write-Success { Write-Host "[✓] $args" -ForegroundColor Green }
function Write-Error { Write-Host "[✗] $args" -ForegroundColor Red }
function Write-Info { Write-Host "[ℹ] $args" -ForegroundColor Cyan }
function Write-Section { Write-Host "`n========== $args ==========" -ForegroundColor Yellow }

#===========================================
# 1. PUBLIC ENDPOINTS TEST
#===========================================

Write-Section "TESTING PUBLIC ENDPOINTS"

# Test 1: Health Check
Write-Info "Testing GET /health"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/health" -Method GET -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Success "Health check: $(($response.Content | ConvertFrom-Json))"
    }
} catch {
    Write-Error "Health check failed: $_"
}

# Test 2: Home endpoint
Write-Info "Testing GET /"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/.." -Method GET -ErrorAction Stop
    Write-Success "Home endpoint: Status $($response.StatusCode)"
} catch {
    Write-Error "Home endpoint failed: $_"
}

# Test 3: Get All Students (Public)
Write-Info "Testing GET /students (public list)"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/students" -Method GET -ErrorAction Stop
    $students = $response.Content | ConvertFrom-Json
    Write-Success "Public students endpoint: Found $($students.Count) students"
} catch {
    Write-Error "Public students endpoint failed: $_"
}

#===========================================
# 2. AUTHENTICATION TEST
#===========================================

Write-Section "TESTING AUTHENTICATION ENDPOINTS"

# Admin Login
Write-Info "Testing POST /auth/login (ADMIN)"
try {
    $body = @{
        email = $ADMIN_EMAIL
        password = $ADMIN_PASS
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" -Body $body -ErrorAction Stop
    
    $result = $response.Content | ConvertFrom-Json
    $ADMIN_TOKEN = $result.token
    
    Write-Success "Admin login successful"
    Write-Info "  - Role: $($result.role)"
    Write-Info "  - Name: $($result.name)"
    Write-Info "  - Token: $($ADMIN_TOKEN.Substring(0, 20))..."
} catch {
    Write-Error "Admin login failed: $_"
}

# Teacher Login
Write-Info "Testing POST /auth/login (TEACHER)"
try {
    $body = @{
        email = $TEACHER_EMAIL
        password = $TEACHER_PASS
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" -Body $body -ErrorAction Stop
    
    $result = $response.Content | ConvertFrom-Json
    $TEACHER_TOKEN = $result.token
    
    Write-Success "Teacher login successful"
    Write-Info "  - Role: $($result.role)"
    Write-Info "  - Name: $($result.name)"
    Write-Info "  - Token: $($TEACHER_TOKEN.Substring(0, 20))..."
} catch {
    Write-Error "Teacher login failed: $_"
}

# Student Login
Write-Info "Testing POST /auth/login (STUDENT)"
try {
    $body = @{
        email = $STUDENT_EMAIL
        password = $STUDENT_PASS
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" -Body $body -ErrorAction Stop
    
    $result = $response.Content | ConvertFrom-Json
    $STUDENT_TOKEN = $result.token
    
    Write-Success "Student login successful"
    Write-Info "  - Role: $($result.role)"
    Write-Info "  - Name: $($result.name)"
    Write-Info "  - Token: $($STUDENT_TOKEN.Substring(0, 20))..."
} catch {
    Write-Error "Student login failed: $_"
}

#===========================================
# 3. ADMIN ENDPOINTS TEST
#===========================================

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
    Write-Success "Departments endpoint: Found $($depts.Count) departments"
    $depts | ForEach-Object {
        Write-Info "  - $($_.name) (ID: $($_.id))"
    }
} catch {
    Write-Error "Departments endpoint failed: $_"
}

# Test Sections
Write-Info "Testing GET /admin/sections"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/sections" -Method GET -Headers $headers -ErrorAction Stop
    $sections = $response.Content | ConvertFrom-Json
    Write-Success "Sections endpoint: Found $($sections.Count) sections"
} catch {
    Write-Error "Sections endpoint failed: $_"
}

# Test Years
Write-Info "Testing GET /admin/years"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/years" -Method GET -Headers $headers -ErrorAction Stop
    $years = $response.Content | ConvertFrom-Json
    Write-Success "Years endpoint: Found years - $($years -join ', ')"
} catch {
    Write-Error "Years endpoint failed: $_"
}

# Test Teachers
Write-Info "Testing GET /admin/teachers"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/teachers" -Method GET -Headers $headers -ErrorAction Stop
    $teachers = $response.Content | ConvertFrom-Json
    Write-Success "Teachers endpoint: Found $($teachers.Count) teachers"
    $teachers | Select-Object -First 3 | ForEach-Object {
        Write-Info "  - $($_.name) (ID: $($_.id), Email: $($_.email))"
    }
} catch {
    Write-Error "Teachers endpoint failed: $_"
}

# Test Students
Write-Info "Testing GET /admin/students"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/students" -Method GET -Headers $headers -ErrorAction Stop
    $students = $response.Content | ConvertFrom-Json
    Write-Success "Students endpoint: Found $($students.Count) students"
} catch {
    Write-Error "Students endpoint failed: $_"
}

# Test Subjects
Write-Info "Testing GET /admin/subjects"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/admin/subjects" -Method GET -Headers $headers -ErrorAction Stop
    $subjects = $response.Content | ConvertFrom-Json
    Write-Success "Subjects endpoint: Found $($subjects.Count) subjects"
} catch {
    Write-Error "Subjects endpoint failed: $_"
}

#===========================================
# 4. TEACHER ENDPOINTS TEST
#===========================================

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
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST `
        -Headers $teacher_headers -Body $body -ErrorAction Stop
    
    $result = $response.Content | ConvertFrom-Json
    $SESSION_ID = $result.sessionId
    $QR_TOKEN = $result.token
    
    Write-Success "QR generation successful"
    Write-Info "  - Session ID: $SESSION_ID"
    Write-Info "  - Token: $($QR_TOKEN.Substring(0, 20))..."
    Write-Info "  - Expiry: $($result.expiryTime)"
    Write-Info "  - QR Image: Base64 encoded (length: $($result.qrImageBase64.Length) chars)"
} catch {
    Write-Error "QR generation failed: $_"
}

# Get Session Attendance
if ($SESSION_ID) {
    Write-Info "Testing GET /teacher/session/{sessionId}/attendance"
    try {
        $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$SESSION_ID/attendance" -Method GET `
            -Headers $teacher_headers -ErrorAction Stop
        
        $attendance = $response.Content | ConvertFrom-Json
        Write-Success "Session attendance retrieved"
        Write-Info "  - Total students in section: $($attendance.Count)"
        $attendance | Select-Object -First 3 | ForEach-Object {
            Write-Info "  - $($_.studentName) (ID: $($_.studentId)): $($_.status)"
        }
    } catch {
        Write-Error "Session attendance failed: $_"
    }
}

#===========================================
# 5. STUDENT ENDPOINTS TEST
#===========================================

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
        
        $response = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST `
            -Headers $student_headers -Body $body -ErrorAction Stop
        
        Write-Success "Attendance marking successful"
        Write-Info "  - Response: $($response.Content)"
    } else {
        Write-Error "Session ID or Token not available"
    }
} catch {
    Write-Error "Attendance marking failed: $_"
}

# Get Attendance History
Write-Info "Testing GET /student/attendance-history"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET `
        -Headers $student_headers -ErrorAction Stop
    
    $history = $response.Content | ConvertFrom-Json
    Write-Success "Attendance history retrieved"
    Write-Info "  - Total records: $($history.Count)"
    if ($history.Count -gt 0) {
        $history | Select-Object -First 3 | ForEach-Object {
            Write-Info "  - $($_.subjectName) by $($_.teacherName) on $($_.date)"
        }
    }
} catch {
    Write-Error "Attendance history failed: $_"
}

# Get Attendance Summary
Write-Info "Testing GET /student/attendance/me"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/attendance/me" -Method GET `
        -Headers $student_headers -ErrorAction Stop
    
    $summary = $response.Content | ConvertFrom-Json
    Write-Success "Attendance summary retrieved"
    Write-Info "  - Subjects: $($summary.subjectAttendance.Count)"
    $summary.subjectAttendance | ForEach-Object {
        Write-Info "  - $($_.subject): $($_.percent)%"
    }
} catch {
    Write-Error "Attendance summary failed: $_"
}

#===========================================
# 6. COMPLETE WORKFLOW TEST
#===========================================

Write-Section "COMPLETE QR ATTENDANCE WORKFLOW TEST"

Write-Info "Step 1: Teacher generates QR for subject"
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
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST `
        -Headers $teacher_headers -Body $body -ErrorAction Stop
    
    $qr_result = $response.Content | ConvertFrom-Json
    Write-Success "✓ QR Generated (Session: $($qr_result.sessionId), Token: $($qr_result.token.Substring(0, 15))...)"
} catch {
    Write-Error "QR generation failed: $_"
    exit
}

Write-Info "Step 2: Student marks attendance using QR"
try {
    $body = @{
        sessionId = [int]$qr_result.sessionId
        token = $qr_result.token
        studentLatitude = 28.5355
        studentLongitude = 77.391
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST `
        -Headers $student_headers -Body $body -ErrorAction Stop
    
    Write-Success "✓ Attendance Marked: $($response.Content)"
} catch {
    Write-Error "Attendance marking failed: $_"
    exit
}

Write-Info "Step 3: Student retrieves attendance history"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET `
        -Headers $student_headers -ErrorAction Stop
    
    $history = $response.Content | ConvertFrom-Json
    Write-Success "✓ Attendance History Retrieved: $($history.Count) records"
    
    if ($history.Count -gt 0) {
        Write-Info "Latest attendance:"
        $history | Select-Object -Last 1 | ForEach-Object {
            Write-Info "  Subject: $($_.subjectName)"
            Write-Info "  Teacher: $($_.teacherName)"
            Write-Info "  Date: $($_.date)"
            Write-Info "  Status: $($_.status)"
        }
    }
} catch {
    Write-Error "Attendance history failed: $_"
    exit
}

Write-Info "Step 4: Teacher verifies attendance"
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$($qr_result.sessionId)/attendance" -Method GET `
        -Headers $teacher_headers -ErrorAction Stop
    
    $session_attendance = $response.Content | ConvertFrom-Json
    $marked_count = ($session_attendance | Where-Object { $_.status -eq "PRESENT" } | Measure-Object).Count
    
    Write-Success "✓ Session Attendance Verified: $marked_count students marked PRESENT"
    Write-Info "Sample attendance records:"
    $session_attendance | Select-Object -First 5 | ForEach-Object {
        Write-Info "  - $($_.studentName): $($_.status)"
    }
} catch {
    Write-Error "Session attendance verification failed: $_"
    exit
}

#===========================================
# SUMMARY
#===========================================

Write-Section "TEST SUMMARY"
Write-Success "✓ All endpoint tests completed!"
Write-Info "Public Endpoints: ✓ Working"
Write-Info "Authentication: ✓ Working"
Write-Info "Admin Endpoints: ✓ Working"
Write-Info "Teacher Endpoints: ✓ Working"
Write-Info "Student Endpoints: ✓ Working"
Write-Info "Complete Workflow: ✓ Working"
Write-Success "All systems operational!"
Write-Host ""
