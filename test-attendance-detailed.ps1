$ErrorActionPreference = "SilentlyContinue"

# Test mark attendance with detailed response info
$BASE_URL = "http://localhost:8080/api"

Write-Host "========== DETAILED ATTENDANCE MARKING TEST ==========" -ForegroundColor Cyan

# Get teacher token
Write-Host "`nStep 1: Getting teacher token..."
try {
    $teacherLogin = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"teacher1@college.com","password":"teacher123"}' `
        -UseBasicParsing
    
    $teacherData = $teacherLogin.Content | ConvertFrom-Json
    $teacherToken = $teacherData.token
    $teacherId = $teacherData.teacherId
    Write-Host "✅ Teacher token obtained (ID: $teacherId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Teacher login failed: $_" -ForegroundColor Red
    exit
}

# Get student token
Write-Host "`nStep 2: Getting student token..."
try {
    $studentLogin = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"student1@college.com","password":"student123"}' `
        -UseBasicParsing
    
    $studentData = $studentLogin.Content | ConvertFrom-Json
    $studentToken = $studentData.token
    Write-Host "✅ Student token obtained" -ForegroundColor Green
} catch {
    Write-Host "❌ Student login failed: $_" -ForegroundColor Red
    exit
}

# Generate QR
Write-Host "`nStep 3: Generating QR..."
try {
    $qrRequest = @{
        teacherId = 1
        teacherName = "Dr. CTeacher0"
        subjectId = 21
        year = 1
        section = "A"
        department = "CS"
        teacherLatitude = 37.7749
        teacherLongitude = -122.4194
        qrExpiryTime = 600000
    } | ConvertTo-Json

    $qrResponse = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST `
        -Headers @{'Authorization'="Bearer $teacherToken"} `
        -ContentType "application/json" `
        -Body $qrRequest `
        -UseBasicParsing
    
    $qrData = $qrResponse.Content | ConvertFrom-Json
    $sessionId = $qrData.sessionId
    $qrToken = $qrData.token
    Write-Host "✅ QR Generated (SessionID: $sessionId)" -ForegroundColor Green
} catch {
    Write-Host "❌ QR generation failed: $_" -ForegroundColor Red
    exit
}

# Mark attendance
Write-Host "`nStep 4: Marking attendance..."
$attendanceRequest = @{
    sessionId = $sessionId
    token = $qrToken
    latitude = 37.7749
    longitude = -122.4194
} | ConvertTo-Json

Write-Host "Request body: $attendanceRequest"

try {
    $attendanceResponse = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST `
        -Headers @{'Authorization'="Bearer $studentToken"} `
        -ContentType "application/json" `
        -Body $attendanceRequest `
        -UseBasicParsing
    
    Write-Host "HTTP Status: $($attendanceResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($attendanceResponse.Content)" -ForegroundColor Green
    Write-Host "✅ Attendance marked successfully" -ForegroundColor Green
} catch [System.Net.WebException] {
    $response = $_.Exception.Response
    Write-Host "HTTP Status: $($response.StatusCode) - $($response.StatusDescription)" -ForegroundColor Red
    
    if ($response.ContentLength -gt 0) {
        $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
        $content = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "Error Response: $content" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Attendance marking failed: $_" -ForegroundColor Red
}

Write-Host "`n====================================================" -ForegroundColor Cyan
