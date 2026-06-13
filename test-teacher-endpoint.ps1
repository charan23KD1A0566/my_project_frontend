$BASE_URL = "http://localhost:8080/api"
$r1 = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="teacher1@college.com"; password="teacher123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
$d1 = $r1.Content | ConvertFrom-Json
$teacherToken = $d1.token

# Try another teacher endpoint
Write-Host "Testing other teacher endpoint..."
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/1/attendance" -Method GET -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
    Write-Host "Works: $($r.StatusCode)"
} catch {
    Write-Host "Error: $($_.Exception.Response.StatusCode)"
}
