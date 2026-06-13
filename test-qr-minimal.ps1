$BASE_URL = "http://localhost:8080/api"

# Get teacher token
$r1 = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="teacher1@college.com"; password="teacher123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
$d1 = $r1.Content | ConvertFrom-Json
$teacherToken = $d1.token

# Try with explicit content type
Write-Host "Test 1: With standard content type..."
$qrBody = @{
    teacherId = 1
    teacherName = "Dr. CTeacher0"
    subjectId = 1
    year = 1
    section = "A"
    department = "CS"
    teacherLatitude = 37.7749
    teacherLongitude = -122.4194
    qrExpiryTime = 600000
} | ConvertTo-Json

try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST -Body $qrBody -ContentType "application/json" -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
    Write-Host "Success! Status: $($r.StatusCode)"
    Write-Host "Response: $($r.Content)"
} catch {
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $errorContent = $reader.ReadToEnd()
    Write-Host "Error: $($_.Exception.Response.StatusCode)"
    Write-Host "Body: '$errorContent'"
    if ($errorContent) {
        Write-Host "Parsed: $($errorContent | ConvertFrom-Json)"
    }
}
