
$API = "https://my-project-80ir.onrender.com/api"

Write-Host "Testing Backend Fix..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Login
Write-Host "[TEST 1] Teacher Login" -ForegroundColor Yellow
$loginBody = @{
  email = "teacher1@college.com"
  password = "teacher123"
  role = "teacher"
} | ConvertTo-Json

$teacher = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
  -Headers @{"Content-Type"="application/json"} -Body $loginBody

Write-Host "✓ Success" -ForegroundColor Green
$token = $teacher.token

# Test 2: QR Gen
Write-Host "[TEST 2] Generate QR" -ForegroundColor Yellow
$qrBody = @{
  teacherId = 1
  teacherName = "Dr. CTeacher0"
  subjectId = 1
  qrExpiryTime = 5
  teacherLatitude = 40.7128
  teacherLongitude = -74.0060
} | ConvertTo-Json

$qr = Invoke-RestMethod -Uri "$API/teacher/generateQR" -Method POST `
  -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $token"} `
  -Body $qrBody

Write-Host "✓ Success" -ForegroundColor Green
Write-Host "  Session: $($qr.sessionId)"
Write-Host "  Token: $($qr.token.Substring(0,20))..."

# Test 3: Student login
Write-Host "[TEST 3] Student Login" -ForegroundColor Yellow
$studentBody = @{
  email = "student1@college.com"
  password = "student123"
  role = "student"
} | ConvertTo-Json

$student = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
  -Headers @{"Content-Type"="application/json"} -Body $studentBody

Write-Host "✓ Success" -ForegroundColor Green
$studentToken = $student.token

# Test 4: Mark attendance
Write-Host "[TEST 4] Mark Attendance" -ForegroundColor Yellow
$attBody = @{
  sessionId = $qr.sessionId
  token = $qr.token
  studentLatitude = 40.7128
  studentLongitude = -74.0060
} | ConvertTo-Json

try {
  $result = Invoke-RestMethod -Uri "$API/student/mark-attendance" -Method POST `
    -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $studentToken"} `
    -Body $attBody
  
  Write-Host "✓ Success" -ForegroundColor Green
  Write-Host "  $result"
} catch {
  Write-Host "✗ Failed" -ForegroundColor Red
  Write-Host "  Error: $($_.Exception.Message)"
}

# Test 5: Check history
Write-Host "[TEST 5] Get Attendance History" -ForegroundColor Yellow
try {
  $history = Invoke-RestMethod -Uri "$API/student/attendance-history" -Method GET `
    -Headers @{"Authorization"="Bearer $studentToken"}
  
  Write-Host "✓ Success" -ForegroundColor Green
  Write-Host "  Records: $($history.Count)"
  
  if ($history.Count -gt 0) {
    $first = $history[0]
    Write-Host "  Latest: $($first.subjectName) on $($first.date)"
  }
} catch {
  Write-Host "✗ Failed" -ForegroundColor Red
  Write-Host "  Error: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "Test Complete!" -ForegroundColor Cyan
