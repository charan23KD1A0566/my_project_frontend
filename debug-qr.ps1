$API = "https://my-project-80ir.onrender.com/api"

Write-Host "Getting teacher token..."
$loginBody = @{
    email = "teacher1@college.com"
    password = "teacher123"
    role = "teacher"
} | ConvertTo-Json

$teacher = Invoke-WebRequest -Uri "$API/auth/login" -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body $loginBody

$token = ($teacher.Content | ConvertFrom-Json).token
Write-Host "Token obtained"

Write-Host "Attempting QR generation..."
$qrBody = @{
    teacherId = 1
    teacherName = "Dr. CTeacher0"
    subjectId = 1
    qrExpiryTime = 5
    teacherLatitude = 40.7128
    teacherLongitude = -74.0060
} | ConvertTo-Json

$qrResp = Invoke-WebRequest -Uri "$API/teacher/generateQR" -Method POST `
    -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $token"} `
    -Body $qrBody `
    -ErrorAction SilentlyContinue

Write-Host "Status Code: $($qrResp.StatusCode)"
Write-Host "Response:"
Write-Host $qrResp.Content
