$baseUrl = "http://localhost:8080/api"

# Test 1: Simple GET request to verify backend is working
Write-Host "Test 1: GET /api/admin/departments"
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/departments" -Method GET -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content.Length) bytes"
} catch {
    Write-Host "Error: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Test 2: POST with empty body to /api/teacher/generateQR
Write-Host "`nTest 2: POST /api/teacher/generateQR with empty body"
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" `
        -Method POST `
        -ContentType "application/json" `
        -Body '{}' `
        -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)"
} catch {
    $err = $_
    Write-Host "Error Status: $($err.Exception.Response.StatusCode)" -ForegroundColor Red
    if ($err.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($err.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "Response: '$body'"
    }
}

# Test 3: POST with minimal fields
Write-Host "`nTest 3: POST /api/teacher/generateQR with minimal JSON"
$minimal = @{teacherId=1} | ConvertTo-Json
Write-Host "Body: $minimal"
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" `
        -Method POST `
        -ContentType "application/json" `
        -Body $minimal `
        -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)"
} catch {
    $err = $_
    Write-Host "Error Status: $($err.Exception.Response.StatusCode)" -ForegroundColor Red
    if ($err.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($err.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "Response: '$body'"
    }
}
