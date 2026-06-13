$API = "http://localhost:8080/api"

# Login as teacher
$login = @{
    email = "teacher1@college.com"
    password = "teacher123"
} | ConvertTo-Json

Write-Host "Logging in as teacher..."
$resp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST -ContentType "application/json" -Body $login
$token = $resp.token
Write-Host "Token obtained: $($token.Substring(0, 20))..."

# Generate QR
$qrBody = @{
    teacherId = 1
    teacherName = "Dr. CTeacher0"
    subjectId = 1
    teacherLatitude = 28.5355
    teacherLongitude = 77.3910
} | ConvertTo-Json

Write-Host "QR Body: $qrBody"

$authHeader = "Bearer $token"
$headers = @{Authorization = $authHeader}

Write-Host "Calling QR generation endpoint..."
try {
    $qrResp = Invoke-RestMethod -Uri "$API/teacher/generateQR" -Method POST -ContentType "application/json" -Body $qrBody -Headers $headers
    Write-Host "QR Generated Successfully!"
    $qrResp | ConvertTo-Json -Depth 2
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Host "Response Body: $body"
    }
}
