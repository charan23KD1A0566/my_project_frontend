$baseUrl = "http://localhost:8080/api"

$minimalBody = @{
    teacherId = 1
    teacherName = "Dr. CTeacher0"
    subjectId = 1
    year = 1
    section = "A"
    department = "CS"
    teacherLatitude = 37.7749
    teacherLongitude = -122.4194
    qrExpiryTime = 600000
}

Write-Host "Testing WITHOUT Authorization header..."
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
        } `
        -Body ($minimalBody | ConvertTo-Json) `
        -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)"
    $response.Content
} catch {
    $err = $_
    Write-Host "Error Status: $($err.Exception.Response.StatusCode) ($($err.Exception.Response.StatusDescription))"
    if ($err.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($err.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "Response Body: '$body'"
    }
}

Write-Host "`n---`n"

# Now test with admin token
$authBody = @{
    email = "admin@gmail.com"
    password = "admin123"
}
$authResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body ($authBody | ConvertTo-Json) -UseBasicParsing
$adminToken = ($authResponse.Content | ConvertFrom-Json).token

Write-Host "Testing WITH ADMIN token (should fail if @PreAuthorize enforced)..."
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $adminToken"
            "Content-Type" = "application/json"
        } `
        -Body ($minimalBody | ConvertTo-Json) `
        -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)"
    $response.Content
} catch {
    $err = $_
    Write-Host "Error Status: $($err.Exception.Response.StatusCode) ($($err.Exception.Response.StatusDescription))"
    if ($err.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($err.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "Response Body: '$body'"
    }
}
