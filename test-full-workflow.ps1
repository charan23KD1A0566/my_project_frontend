$API = "http://localhost:8080/api"

Write-Host "=== COMPLETE QR WORKFLOW TEST ===" -ForegroundColor Green
Write-Host ""

# ===== STEP 1: TEACHER GENERATES QR =====
Write-Host "STEP 1: Teacher generates QR code" -ForegroundColor Cyan

$teacherLogin = @{
    email = "teacher1@college.com"
    password = "teacher123"
} | ConvertTo-Json

$teacherResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST -ContentType "application/json" -Body $teacherLogin
$teacherToken = $teacherResp.token
$teacherHeaders = @{Authorization = "Bearer $teacherToken"}
Write-Host "OK: Teacher logged in: $($teacherResp.name)"

$qrReq = @{
    teacherId = 1
    teacherName = "Dr. CTeacher0"
    subjectId = 21
    teacherLatitude = 28.5355
    teacherLongitude = 77.391
    qrExpiryTime = 10
} | ConvertTo-Json

$qrResp = Invoke-RestMethod -Uri "$API/teacher/generateQR" -Method POST -ContentType "application/json" -Body $qrReq -Headers $teacherHeaders
$sessionId = $qrResp.sessionId
$token = $qrResp.token
Write-Host "OK: QR generated - Session $sessionId, Token $token"
Write-Host ""

# ===== STEP 2: STUDENT MARKS ATTENDANCE =====
Write-Host "STEP 2: Student marks attendance using QR" -ForegroundColor Cyan

$studentLogin = @{
    email = "student1@college.com"
    password = "student123"
} | ConvertTo-Json

$studentResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST -ContentType "application/json" -Body $studentLogin
$studentToken = $studentResp.token
$studentHeaders = @{Authorization = "Bearer $studentToken"}
Write-Host "OK: Student logged in: $($studentResp.name)"

$attendanceReq = @{
    sessionId = $sessionId
    token = $token
    studentLatitude = 28.5355
    studentLongitude = 77.391
} | ConvertTo-Json

try {
    $attendanceResp = Invoke-RestMethod -Uri "$API/student/mark-attendance" -Method POST -ContentType "application/json" -Body $attendanceReq -Headers $studentHeaders
    Write-Host "OK: Attendance marked - Response: $attendanceResp"
} catch {
    Write-Host "ERROR: Attendance marking failed - $($_.Exception.Message)"
}

Write-Host ""

# ===== STEP 3: VERIFY ATTENDANCE =====
Write-Host "STEP 3: Verify attendance was recorded" -ForegroundColor Cyan

try {
    $attendanceList = Invoke-RestMethod -Uri "$API/student/attendance-history" -Method GET -Headers $studentHeaders
    Write-Host "OK: Retrieved $($attendanceList.Count) attendance records"
} catch {
    Write-Host "ERROR: Failed to retrieve history - $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== TEST COMPLETE ===" -ForegroundColor Green
