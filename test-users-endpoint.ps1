$BASE_URL = "http://localhost:8080/api"

# Get admin token
Write-Host "Getting admin token..."
$adminLogin = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -ContentType "application/json" -Body '{"email":"admin@gmail.com","password":"admin123"}' -UseBasicParsing
$adminData = $adminLogin.Content | ConvertFrom-Json
$adminToken = $adminData.token
Write-Host "✅ Token obtained"

# Call users endpoint
Write-Host "Calling /api/admin/users..."
$startTime = Get-Date
$response = Invoke-WebRequest -Uri "$BASE_URL/admin/users" -Method GET -Headers @{"Authorization"="Bearer $adminToken"} -UseBasicParsing
$endTime = Get-Date

$timeSpent = ($endTime - $startTime).TotalSeconds
Write-Host "✅ Response received in $timeSpent seconds"
Write-Host "Status: $($response.StatusCode)"

$users = $response.Content | ConvertFrom-Json
Write-Host "Found $($users.Count) users"
