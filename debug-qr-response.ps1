$teacherEmail = "teacher1@college.com"
$teacherPassword = "teacher123"
$baseUrl = "http://localhost:8080/api"

Write-Host "=== Debugging QR Generation Error ===" -ForegroundColor Cyan

# Step 1: Authenticate teacher
Write-Host "1. Authenticating teacher..." -ForegroundColor Yellow
$authBody = @{
    email = $teacherEmail
    password = $teacherPassword
}
$authResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body ($authBody | ConvertTo-Json) -UseBasicParsing

$d = $authResponse.Content | ConvertFrom-Json
$teacherToken = $d.token
$teacherId = $d.id
$teacherName = $d.name
Write-Host "Teacher ID: $teacherId" -ForegroundColor Green
Write-Host "Teacher Name: $teacherName" -ForegroundColor Green
Write-Host "Token: $($teacherToken.Substring(0, 50))..." -ForegroundColor Green

# Step 2: Build QR request
Write-Host "`n2. Building QR Generation Request..." -ForegroundColor Yellow
$qrBody = @{
    teacherId = $teacherId
    teacherName = $teacherName
    subjectId = 1
    year = 1
    section = "A"
    department = "CS"
    teacherLatitude = 37.7749
    teacherLongitude = -122.4194
    qrExpiryTime = 600000
}
Write-Host "Request Body:"
$qrBody | ConvertTo-Json | Write-Host

# Step 3: Call QR endpoint
Write-Host "`n3. Calling QR Generation Endpoint..." -ForegroundColor Yellow
try {
    $qrResponse = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" -Method POST -ContentType "application/json" -Body ($qrBody | ConvertTo-Json) -Headers @{"Authorization" = "Bearer $teacherToken"} -UseBasicParsing
    Write-Host "Status: $($qrResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Green
    $qrResponse.Content | Write-Host
} catch {
    $errorResponse = $_.Exception.Response
    Write-Host "Status: $($errorResponse.StatusCode)" -ForegroundColor Red
    Write-Host "Status Description: $($errorResponse.StatusDescription)" -ForegroundColor Red
    
    $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
    $responseBody = $reader.ReadToEnd()
    $reader.Close()
    
    Write-Host "Error Response Body:" -ForegroundColor Red
    Write-Host $responseBody
}
