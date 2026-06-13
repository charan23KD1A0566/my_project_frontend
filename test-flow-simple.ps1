# FULL WORKFLOW TEST - Detailed Output
$BASE_URL = "http://localhost:8080/api"

Clear-Host
Write-Host "================================" -ForegroundColor Cyan
Write-Host "FULL WORKFLOW TEST" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# PHASE 1: AUTH
Write-Host "`nPHASE 1: AUTHENTICATION" -ForegroundColor Yellow

try {
    $adminResp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{email="admin@gmail.com"; password="admin123"} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $adminData = $adminResp.Content | ConvertFrom-Json
    $adminToken = $adminData.token
    Write-Host "OK: Admin login - Role: $($adminData.role)"
} catch {
    Write-Host "ERROR: Admin login failed - $($_.Exception.Message)"
}

try {
    $teacherResp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{email="CTeacher0@gmail.com"; password="Teacher@123"} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $teacherData = $teacherResp.Content | ConvertFrom-Json
    $teacherToken = $teacherData.token
    Write-Host "OK: Teacher login - Name: $($teacherData.name)"
} catch {
    Write-Host "ERROR: Teacher login - $($_.Exception.Message)"
}

try {
    $studentResp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{rollNumber="00001"; password="pass123"} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $studentData = $studentResp.Content | ConvertFrom-Json
    $studentToken = $studentData.token
    Write-Host "OK: Student login - Name: $($studentData.name)"
} catch {
    Write-Host "ERROR: Student login - $($_.Exception.Message)"
}

# PHASE 2: ADMIN DATA
Write-Host "`nPHASE 2: ADMIN DATA" -ForegroundColor Yellow

try {
    $depts = Invoke-WebRequest -Uri "$BASE_URL/admin/departments" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $deptData = $depts.Content | ConvertFrom-Json
    Write-Host "OK: Departments - $($deptData.Count) found"
} catch { Write-Host "ERROR: Departments - $($_.Exception.Message)" }

try {
    $teachers = Invoke-WebRequest -Uri "$BASE_URL/admin/teachers" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $teacherListData = $teachers.Content | ConvertFrom-Json
    Write-Host "OK: Teachers - $($teacherListData.Count) found"
} catch { Write-Host "ERROR: Teachers - $($_.Exception.Message)" }

try {
    $students = Invoke-WebRequest -Uri "$BASE_URL/admin/students" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $studentListData = $students.Content | ConvertFrom-Json
    Write-Host "OK: Students - $($studentListData.Count) found"
} catch { Write-Host "ERROR: Students - $($_.Exception.Message)" }

try {
    $subjects = Invoke-WebRequest -Uri "$BASE_URL/admin/subjects" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $subjectData = $subjects.Content | ConvertFrom-Json
    Write-Host "OK: Subjects - $($subjectData.Count) found"
} catch { Write-Host "ERROR: Subjects - $($_.Exception.Message)" }

# PHASE 3: TEACHER QR
Write-Host "`nPHASE 3: TEACHER QR GENERATION" -ForegroundColor Yellow

if ($teacherToken) {
    try {
        $qrResp = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST `
            -Body (@{subjectId=1; latitude=37.7749; longitude=-122.4194} | ConvertTo-Json) `
            -ContentType "application/json" `
            -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
        $qrData = $qrResp.Content | ConvertFrom-Json
        $sessionId = $qrData.sessionId
        Write-Host "OK: QR Generated - Session: $sessionId"
        
        # Session attendance before marking
        try {
            $sessAtt = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$sessionId/attendance" -Method GET `
                -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
            $sessAttData = $sessAtt.Content | ConvertFrom-Json
            Write-Host "OK: Session attendance (before) - $($sessAttData.Count) records"
        } catch { Write-Host "ERROR: Session attendance - $($_.Exception.Message)" }
    } catch {
        Write-Host "ERROR: QR Generation - $($_.Exception.Message)"
    }
}

# PHASE 4: STUDENT ATTENDANCE
Write-Host "`nPHASE 4: STUDENT ATTENDANCE" -ForegroundColor Yellow

if ($studentToken -and $qrData -and $qrData.sessionId -and $qrData.token) {
    try {
        $attResp = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST `
            -Body (@{sessionId=$qrData.sessionId; token=$qrData.token; latitude=37.7749; longitude=-122.4194} | ConvertTo-Json) `
            -ContentType "application/json" `
            -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $attData = $attResp.Content | ConvertFrom-Json
        Write-Host "OK: Attendance marked - Status: $($attData.status)"
    } catch {
        Write-Host "ERROR: Mark attendance - $($_.Exception.Message)"
    }
    
    try {
        $histResp = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET `
            -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $histData = $histResp.Content | ConvertFrom-Json
        Write-Host "OK: Attendance history - $($histData.Count) records"
    } catch { Write-Host "ERROR: Attendance history - $($_.Exception.Message)" }
    
    try {
        $summResp = Invoke-WebRequest -Uri "$BASE_URL/student/attendance/me" -Method GET `
            -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $summData = $summResp.Content | ConvertFrom-Json
        Write-Host "OK: Attendance summary - $($summData.Count) subjects"
    } catch { Write-Host "ERROR: Attendance summary - $($_.Exception.Message)" }
}

# PHASE 5: VERIFICATION
Write-Host "`nPHASE 5: VERIFICATION" -ForegroundColor Yellow

if ($teacherToken -and $qrData -and $qrData.sessionId) {
    try {
        $finalResp = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$($qrData.sessionId)/attendance" -Method GET `
            -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
        $finalData = $finalResp.Content | ConvertFrom-Json
        Write-Host "OK: Final session attendance - $($finalData.Count) total records"
    } catch { Write-Host "ERROR: Final check - $($_.Exception.Message)" }
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
