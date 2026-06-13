$BASE_URL = "http://localhost:8080/api"
$r1 = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="teacher1@college.com"; password="teacher123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
$d1 = $r1.Content | ConvertFrom-Json
$teacherToken = $d1.token

Write-Host "Test 1: Empty POST body..."
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST -Body "" -ContentType "application/json" -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
    Write-Host "Status: $($r.StatusCode)"
} catch {
    Write-Host "Error: $($_.Exception.Response.StatusCode)"
}

Write-Host "`nTest 2: Minimal valid JSON..."
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST -Body '{}' -ContentType "application/json" -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
    Write-Host "Status: $($r.StatusCode)"
} catch {
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $body = $reader.ReadToEnd()
    Write-Host "Error: $($_.Exception.Response.StatusCode)"
    Write-Host "Body: '$body'"
    $reader.Close()
}
