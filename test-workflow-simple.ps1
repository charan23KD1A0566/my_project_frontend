$API = "https://my-project-80ir.onrender.com/api"

# Login as teacher
Write-Host "Step 1: Teacher Login..." -ForegroundColor Cyan
$teacher = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"teacher1@college.com","password":"teacher123","role":"teacher"}'

Write-Host "Teacher logged in: $($teacher.email)" -ForegroundColor Green
$teacherToken = $teacher.token

# Generate QR
Write-Host "Step 2: Generate QR..." -ForegroundColor Cyan
$qr = Invoke-RestMethod -Uri "$API/teacher/generateQR" -Method POST `
  -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $teacherToken"} `
  -Body '{"teacherId":1,"teacherName":"Dr. CTeacher0","subjectId":1,"qrExpiryTime":5,"teacherLatitude":40.7128,"teacherLongitude":-74.0060}'

Write-Host "QR Generated - Session: $($qr.sessionId), Token: $($qr.token.Substring(0,10))..." -ForegroundColor Green
$sessionId = $qr.sessionId
$qrToken = $qr.token

# Login as student
Write-Host "Step 3: Student Login..." -ForegroundColor Cyan
$student = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"student1@college.com","password":"student123","role":"student"}'

Write-Host "Student logged in: $($student.email)" -ForegroundColor Green
$studentToken = $student.token

# Mark attendance
Write-Host "Step 4: Mark Attendance..." -ForegroundColor Cyan
try {
  $attendance = Invoke-RestMethod -Uri "$API/student/mark-attendance" -Method POST `
    -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $studentToken"} `
    -Body "{`"sessionId`":$sessionId,`"token`":`"$qrToken`",`"studentLatitude`":40.7128,`"studentLongitude`":-74.0060}"
  
  Write-Host "SUCCESS: $attendance" -ForegroundColor Green
} catch {
  Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
  $_.Exception | Get-Member
}

# Get attendance history
Write-Host "Step 5: Get Attendance History..." -ForegroundColor Cyan
try {
  $history = Invoke-RestMethod -Uri "$API/student/attendance-history" -Method GET `
    -Headers @{"Authorization"="Bearer $studentToken"}
  
  Write-Host "History Count: $($history.Count)" -ForegroundColor Green
  if ($history -and $history.Count -gt 0) {
    Write-Host "Latest: $($history[0] | ConvertTo-Json)" -ForegroundColor Green
  }
} catch {
  Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
