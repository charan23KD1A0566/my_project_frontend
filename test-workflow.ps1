$API = "https://my-project-80ir.onrender.com/api"

Write-Host "Testing QR Workflow..." -ForegroundColor Cyan
Write-Host ""

try {
    # Test 1: Teacher Login
    Write-Host "[TEST 1] Teacher Login" -ForegroundColor Yellow
    $loginBody = @{
        email = "teacher1@college.com"
        password = "teacher123"
        role = "teacher"
    } | ConvertTo-Json

    $teacher = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type"="application/json"} -Body $loginBody

    Write-Host "SUCCESS" -ForegroundColor Green
    $token = $teacher.token
    Write-Host "Token: $($token.Substring(0,20))..."
    Write-Host ""

    # Test 2: Generate QR
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

    Write-Host "SUCCESS" -ForegroundColor Green
    Write-Host "Session ID: $($qr.sessionId)"
    Write-Host "Token: $($qr.token.Substring(0,20))..."
    Write-Host ""

    # Test 3: Student Login
    Write-Host "[TEST 3] Student Login" -ForegroundColor Yellow
    $studentBody = @{
        email = "student1@college.com"
        password = "student123"
        role = "student"
    } | ConvertTo-Json

    $student = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type"="application/json"} -Body $studentBody

    Write-Host "SUCCESS" -ForegroundColor Green
    $studentToken = $student.token
    Write-Host "Token: $($studentToken.Substring(0,20))..."
    Write-Host ""

    # Test 4: Mark Attendance
    Write-Host "[TEST 4] Mark Attendance" -ForegroundColor Yellow
    $attBody = @{
        sessionId = $qr.sessionId
        token = $qr.token
        studentLatitude = 40.7128
        studentLongitude = -74.0060
    } | ConvertTo-Json

    $result = Invoke-RestMethod -Uri "$API/student/mark-attendance" -Method POST `
        -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $studentToken"} `
        -Body $attBody

    Write-Host "SUCCESS" -ForegroundColor Green
    Write-Host "Result: $result"
    Write-Host ""

    # Test 5: Get Attendance History
    Write-Host "[TEST 5] Attendance History" -ForegroundColor Yellow
    $history = Invoke-RestMethod -Uri "$API/student/attendance-history" -Method GET `
        -Headers @{"Authorization"="Bearer $studentToken"}

    Write-Host "SUCCESS" -ForegroundColor Green
    Write-Host "Records: $($history.Count)"
    if ($history.Count -gt 0) {
        Write-Host "Latest: $($history[0].subjectName)"
    }
    Write-Host ""

} catch {
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "Test Complete!" -ForegroundColor Cyan
