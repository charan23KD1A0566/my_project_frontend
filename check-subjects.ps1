#!/usr/bin/env powershell

$API = "https://my-project-80ir.onrender.com/api"

# Get admin token
$admin = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body (ConvertTo-Json @{email='admin@gmail.com';password='admin123';role='admin'})

$token = $admin.token

# Get subjects
Write-Host "Getting Subjects..." -ForegroundColor Cyan
try {
    $subjects = Invoke-RestMethod -Uri "$API/admin/subjects" -Method GET `
        -Headers @{"Authorization"="Bearer $token"}
    
    Write-Host "Found $($subjects.Count) subjects" -ForegroundColor Green
    
    Write-Host "`nFirst 5 subjects:" -ForegroundColor Yellow
    foreach ($s in $subjects[0..4]) {
        Write-Host "ID: $($s.id), Name: $($s.name), Dept: $($s.department.name), Year: $($s.year), Section: $($s.section.sectionName), Teacher: $($s.teacher.name)" -ForegroundColor Cyan
    }
    
    # Check if subject 1 exists
    $subj1 = $subjects | Where-Object { $_.id -eq 1 }
    if ($subj1) {
        Write-Host "`n✅ Subject ID 1 EXISTS: $($subj1.name)" -ForegroundColor Green
        Write-Host "   Teacher: $($subj1.teacher.name)" -ForegroundColor Cyan
        Write-Host "   Section: $($subj1.section.sectionName)" -ForegroundColor Cyan
    } else {
        Write-Host "`n❌ Subject ID 1 NOT FOUND" -ForegroundColor Red
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
