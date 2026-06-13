$baseUrl = "http://localhost:8080/api"

# 1. Get teacher token
Write-Host "1️⃣  Authenticating teacher..."
$teacherLogin = Invoke-WebRequest -Uri "$baseUrl/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"teacher1@college.com","password":"teacher123"}' `
    -UseBasicParsing

$teacherData = $teacherLogin.Content | ConvertFrom-Json
$teacherToken = $teacherData.token
$teacherId = $teacherData.id
$teacherName = $teacherData.name

Write-Host "✅ Teacher authenticated"
Write-Host "   Token: $($teacherToken.Substring(0, 50))..."
Write-Host "   ID: $teacherId"
Write-Host "   Name: $teacherName"

# 2. Generate QR with VALID subject ID (21 instead of 1)
Write-Host "`n2️⃣  Generating QR..."

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

Write-Host "   Request Body: $qrRequest"

$headers = @{
    "Authorization" = "Bearer $teacherToken"
    "Content-Type" = "application/json"
}

try {
    $qrResponse = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" `
        -Method POST `
        -Headers $headers `
        -Body $qrRequest `
        -UseBasicParsing
    
    $qrData = $qrResponse.Content | ConvertFrom-Json
    
    Write-Host "✅ QR Generated Successfully!"
    Write-Host "   Session ID: $($qrData.sessionId)"
    Write-Host "   Token: $($qrData.token.Substring(0, 50))..."
    Write-Host "   Expiry: $($qrData.expiryTime)"
    Write-Host "   QR Image: $($qrData.qrImageBase64.Substring(0, 50))..."
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "   Status: $($_.Exception.Response.StatusCode)"
        Write-Host "   Body: $($_.Exception.Response | Get-Member)"
    }
}
