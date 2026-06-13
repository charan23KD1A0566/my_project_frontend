$API = "http://localhost:8080/api"

# Admin login
$adminLogin = @{
    email = "admin@gmail.com"
    password = "admin123"
} | ConvertTo-Json

$adminResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST -ContentType "application/json" -Body $adminLogin
$adminToken = $adminResp.token
$adminHeaders = @{Authorization = "Bearer $adminToken"}

# Get subject 21 details
$subject21 = Invoke-RestMethod -Uri "$API/admin/subjects/21" -Method GET -Headers $adminHeaders
Write-Host "Subject 21 Details:"
$subject21 | ConvertTo-Json -Depth 3

Write-Host "`nTeacher in Subject 21:"
if ($subject21.teacher) {
    $subject21.teacher | ConvertTo-Json -Depth 2
} else {
    Write-Host "TEACHER IS NULL!"
}
