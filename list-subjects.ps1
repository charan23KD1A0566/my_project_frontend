$baseUrl = "http://localhost:8080/api"

# Get admin token
$loginResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"admin@gmail.com","password":"admin123"}' `
    -ErrorAction Stop

$loginData = $loginResponse.Content | ConvertFrom-Json
$adminToken = $loginData.token

Write-Host "Admin Token received"

# Get subjects
$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}

$subjectsResponse = Invoke-WebRequest -Uri "$baseUrl/admin/subjects" `
    -Method GET `
    -Headers $headers `
    -ErrorAction Stop

$subjects = $subjectsResponse.Content | ConvertFrom-Json

Write-Host "Total subjects: $($subjects.Count)"
Write-Host "`nFirst 5 subjects:"
$subjects | Select-Object -First 5 | ForEach-Object {
    Write-Host "ID: $($_.id), Name: $($_.name)"
}
