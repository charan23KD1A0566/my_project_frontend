$BASE_URL = "http://localhost:8080/api"

# Step 1: Teacher auth
Write-Host "Step 1: Teacher authentication..."
$r1 = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="teacher1@college.com"; password="teacher123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
$d1 = $r1.Content | ConvertFrom-Json
$teacherToken = $d1.token
$teacherId = $d1.id
$teacherName = $d1.name
Write-Host "Teacher: ID=$teacherId, Name=$teacherName"

# Step 2: QR generation
Write-Host "`nStep 2: QR Generation..."
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

Write-Host "Request body:"
$jsonBody = $qrBody | ConvertTo-Json
Write-Host $jsonBody

try {
    $r2 = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST -Body $jsonBody -ContentType "application/json" -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
    Write-Host "Success! Status: $($r2.StatusCode)"
    $d2 = $r2.Content | ConvertFrom-Json
    Write-Host $d2 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "HTTP Status: $($_.Exception.Response.StatusCode)"
    Write-Host "Status Description: $($_.Exception.Response.StatusDescription)"
    
    # Try to read response content
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $errorContent = $reader.ReadToEnd()
    Write-Host "Error Response: '$errorContent'"
    $reader.Close()
}
