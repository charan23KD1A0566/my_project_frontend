$baseUrl = "http://localhost:8080/api"

# Get teacher token and ID
$teacherLogin = Invoke-WebRequest -Uri "$baseUrl/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"teacher1@college.com","password":"teacher123"}' `
    -UseBasicParsing
$teacherData = $teacherLogin.Content | ConvertFrom-Json
$teacherToken = $teacherData.token
$teacherId = $teacherData.id
$teacherName = $teacherData.name

# Generate QR
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

$headers = @{
    "Authorization" = "Bearer $teacherToken"
    "Content-Type" = "application/json"
}

$qrResponse = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" `
    -Method POST `
    -Headers $headers `
    -Body $qrRequest `
    -UseBasicParsing
$qrData = $qrResponse.Content | ConvertFrom-Json
$sessionId = $qrData.sessionId
$qrToken = $qrData.token

Write-Host "✅ QR Generated - SessionID: $sessionId"

# Get student token
$studentLogin = Invoke-WebRequest -Uri "$baseUrl/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"student1@college.com","password":"student123"}' `
    -UseBasicParsing
$studentData = $studentLogin.Content | ConvertFrom-Json
$studentToken = $studentData.token

Write-Host "✅ Student authenticated"

# Mark attendance with detailed error handling
Write-Host "`nMarking attendance..."
Write-Host "  SessionID: $sessionId"
Write-Host "  Token: $($qrToken.Substring(0, 20))..."
Write-Host "  Latitude: 37.7749, Longitude: -122.4194"

$attendanceBody = @{
    sessionId = $sessionId
    token = $qrToken
    latitude = 37.7749
    longitude = -122.4194
} | ConvertTo-Json

Write-Host "`nRequest body: $attendanceBody"

$studentHeaders = @{
    "Authorization" = "Bearer $studentToken"
    "Content-Type" = "application/json"
}

try {
    $attendanceResponse = Invoke-WebRequest -Uri "$baseUrl/student/mark-attendance" `
        -Method POST `
        -Headers $studentHeaders `
        -Body $attendanceBody `
        -UseBasicParsing
    
    $attendanceData = $attendanceResponse.Content | ConvertFrom-Json
    Write-Host "`n✅ Attendance marked!"
    Write-Host "Response: $($attendanceResponse.Content)"
}
catch {
    Write-Host "`n❌ Error marking attendance"
    Write-Host "Status: $($_.Exception.Response.StatusCode)"
    Write-Host "Response: $($_.Exception.Response)"
    
    # Try to read response content
    try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $content = $reader.ReadToEnd()
        Write-Host "Response Body: $content"
    } catch {
        Write-Host "Could not read response body"
    }
}
