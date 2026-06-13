#!/usr/bin/env powershell

$API = "https://my-project-80ir.onrender.com/api"

# Get admin token
$admin = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body (ConvertTo-Json @{email='admin@gmail.com';password='admin123';role='admin'})

Write-Host "Getting teachers JSON..."
$response = Invoke-WebRequest -Uri "$API/admin/teachers" -Method GET `
    -Headers @{"Authorization"="Bearer $($admin.token)"} `
    -UseBasicParsing

Write-Host "First 300 characters of response:" -ForegroundColor Cyan
Write-Host $response.Content.Substring(0, 300)

Write-Host "`nTrying to parse..." -ForegroundColor Yellow
$data = $response.Content | ConvertFrom-Json
if ($data.Count -gt 0) {
    $first = $data[0]
    Write-Host "First teacher object keys:" -ForegroundColor Green
    $first.PSObject.Properties | ForEach-Object { Write-Host "  - $($_.Name): $($_.Value)" }
}
