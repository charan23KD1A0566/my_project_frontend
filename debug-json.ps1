#!/usr/bin/env powershell

$API = "https://my-project-80ir.onrender.com/api"

# Get admin token
$admin = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body (ConvertTo-Json @{email='admin@gmail.com';password='admin123';role='admin'})

$adminToken = $admin.token

Write-Host "Getting raw teacher JSON..." -ForegroundColor Cyan

# Get teachers and show raw response
$response = Invoke-WebRequest -Uri "$API/admin/teachers" -Method GET `
    -Headers @{"Authorization"="Bearer $adminToken"} `
    -UseBasicParsing

Write-Host "HTTP Status: $($response.StatusCode)" -ForegroundColor Green
Write-Host "Content-Type: $($response.Headers['Content-Type'])" -ForegroundColor Green
Write-Host ""
Write-Host "Raw Response:" -ForegroundColor Cyan
Write-Host $response.Content

Write-Host ""
Write-Host "Parsing JSON..." -ForegroundColor Yellow
$data = $response.Content | ConvertFrom-Json
Write-Host "Parsed count: $($data.Count)"
if ($data.Count -gt 0) {
    Write-Host "First item: $($data[0] | ConvertTo-Json -Depth 3)" -ForegroundColor Cyan
}
