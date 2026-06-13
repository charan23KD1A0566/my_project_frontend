$BASE_URL = "http://localhost:8080/api"

Write-Host "Testing teacher authentication..."
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="teacher1@college.com"; password="teacher123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "Response:"
    Write-Host $d | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
