# WORKFLOW TEST - Detailed System Lifecycle
$BASE_URL = "http://localhost:8080/api"
$ADMIN_EMAIL = "admin@gmail.com"
$ADMIN_PASS = "admin123"
$TEACHER_EMAIL = "CTeacher0@gmail.com"
$TEACHER_PASS = "Teacher@123"
$STUDENT_ROLL = "00001"
$STUDENT_PASS = "pass123"

Clear-Host
Write-Host "=== FULL WORKFLOW TEST ===" -ForegroundColor Cyan

# PHASE 1: LOGIN
Write-Host "`n[PHASE 1] AUTHENTICATION" -ForegroundColor Yellow

try {
    $adminResp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{email=$ADMIN_EMAIL; password=$ADMIN_PASS} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $adminData = $adminResp.Content | ConvertFrom-Json
    $adminToken = $adminData.token
    Write-Host "[OK] Admin login successful" -ForegroundColor Green
} catch { Write-Host "[ERROR] Admin login failed" -ForegroundColor Red }

try {
    $teacherResp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{email=$TEACHER_EMAIL; password=$TEACHER_PASS} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $teacherData = $teacherResp.Content | ConvertFrom-Json
    $teacherToken = $teacherData.token
    Write-Host "[OK] Teacher login successful" -ForegroundColor Green
} catch { Write-Host "[ERROR] Teacher login failed" -ForegroundColor Red }

try {
    $studentResp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{rollNumber=$STUDENT_ROLL; password=$STUDENT_PASS} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $studentData = $studentResp.Content | ConvertFrom-Json
    $studentToken = $studentData.token
    Write-Host "[OK] Student login successful" -ForegroundColor Green
} catch { Write-Host "[ERROR] Student login failed" -ForegroundColor Red }

# PHASE 2: DATA VERIFICATION
Write-Host "`n[PHASE 2] ADMIN ENDPOINTS" -ForegroundColor Yellow

try {
    $depts = Invoke-WebRequest -Uri "$BASE_URL/admin/departments" -Method GET `
        -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $deptData = $depts.Content | ConvertFrom-Json
    Write-Host "[OK] Departments: $($deptData.Count)" -ForegroundColor Green
} catch { Write-Host "[ERROR] Departments failed" -ForegroundColor Red }

try {
    $teachers = Invoke-WebRequest -Uri "$BASE_URL/admin/teachers" -Method GET `
        -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $teacherData = $teachers.Content | ConvertFrom-Json
    Write-Host "[OK] Teachers: $($teacherData.Count)" -ForegroundColor Green
} catch { Write-Host "[ERROR] Teachers failed" -ForegroundColor Red }

try {
    $students = Invoke-WebRequest -Uri "$BASE_URL/admin/students" -Method GET `
        -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $studentData = $students.Content | ConvertFrom-Json
    Write-Host "[OK] Students: $($studentData.Count)" -ForegroundColor Green
} catch { Write-Host "[ERROR] Students failed" -ForegroundColor Red }

try {
    $subjects = Invoke-WebRequest -Uri "$BASE_URL/admin/subjects" -Method GET `
        -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $subjectData = $subjects.Content | ConvertFrom-Json
    Write-Host "[OK] Subjects: $($subjectData.Count)" -ForegroundColor Green
} catch { Write-Host "[ERROR] Subjects failed" -ForegroundColor Red }

# PHASE 3: TEACHER QR GENERATION
Write-Host "`n[PHASE 3] TEACHER QR GENERATION" -ForegroundColor Yellow

try {
    $qrBody = @{
        subjectId = 1
        latitude = 37.7749
        longitude = -122.4194
    } | ConvertTo-Json
    
    $qrResp = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST `
        -Body $qrBody -ContentType "application/json" `
        -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
    $qrData = $qrResp.Content | ConvertFrom-Json
    $sessionId = $qrData.sessionId
    $qrToken = $qrData.token
    Write-Host "[OK] QR generated - SessionID: $sessionId" -ForegroundColor Green
} catch { 
    Write-Host "[ERROR] QR generation failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# PHASE 4: STUDENT ATTENDANCE
Write-Host "`n[PHASE 4] STUDENT ATTENDANCE" -ForegroundColor Yellow

if ($sessionId -and $qrToken) {
    try {
        $attendBody = @{
            sessionId = $sessionId
            token = $qrToken
            latitude = 37.7749
            longitude = -122.4194
        } | ConvertTo-Json
        
        $attResp = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST `
            -Body $attendBody -ContentType "application/json" `
            -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $attData = $attResp.Content | ConvertFrom-Json
        Write-Host "[OK] Attendance marked - Status: $($attData.status)" -ForegroundColor Green
    } catch { Write-Host "[ERROR] Mark attendance failed" -ForegroundColor Red }
    
    try {
        $histResp = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET `
            -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $histData = $histResp.Content | ConvertFrom-Json
        Write-Host "[OK] Attendance history: $($histData.Count) records" -ForegroundColor Green
    } catch { Write-Host "[ERROR] History failed" -ForegroundColor Red }
}

# PHASE 5: VERIFICATION
Write-Host "`n[PHASE 5] VERIFICATION" -ForegroundColor Yellow

if ($sessionId) {
    try {
        $sessResp = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$sessionId/attendance" -Method GET `
            -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
        $sessData = $sessResp.Content | ConvertFrom-Json
        Write-Host "[OK] Session attendance: $($sessData.Count) students" -ForegroundColor Green
    } catch { Write-Host "[ERROR] Session attendance failed" -ForegroundColor Red }
}

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Cyan
